package kpfu.itis.marketbroker.producer;

import kpfu.itis.marketbroker.config.AppConfig;
import kpfu.itis.marketbroker.db.BrokerChannels;
import kpfu.itis.marketbroker.db.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Locale;
import java.util.concurrent.ThreadLocalRandom;

/**
 * Producer генерирует поток событий маркетплейса.
 *
 * Главная идея: задача в очереди создается в той же транзакции, что и
 * бизнес-событие. Поэтому не бывает ситуации, когда событие заказа записалось,
 * а задача на обработку доставки потерялась.
 */
public final class MarketplaceProducer {
    public void run() throws Exception {
        int ratePerSecond = AppConfig.intEnv("PRODUCER_RATE_PER_SECOND", 250);
        int criticalPercent = AppConfig.intEnv("PRODUCER_CRITICAL_PERCENT", 20);
        long pauseNanos = 1_000_000_000L / Math.max(1, ratePerSecond);
        long nextTick = System.nanoTime();
        long produced = 0;
        long critical = 0;
        long normal = 0;
        long lastLogAt = System.currentTimeMillis();

        try (Connection connection = Database.openConnection("producer")) {
            System.out.printf("producer started: rate=%d/s critical=%d%%%n", ratePerSecond, criticalPercent);
            while (true) {
                int priority = produceOne(connection, criticalPercent);
                produced++;
                if (priority == 100) {
                    critical++;
                } else {
                    normal++;
                }

                long nowMillis = System.currentTimeMillis();
                if (nowMillis - lastLogAt >= 1_000) {
                    System.out.printf("producer produced=%d normal=%d critical=%d%n", produced, normal, critical);
                    lastLogAt = nowMillis;
                }

                // Держим заданную интенсивность: 250/s означает примерно одну
                // вставку каждые 4 мс, а не "как получится после предыдущего INSERT".
                nextTick += pauseNanos;
                long sleepNanos = nextTick - System.nanoTime();
                if (sleepNanos > 0) {
                    Thread.sleep(sleepNanos / 1_000_000L, (int) (sleepNanos % 1_000_000L));
                } else if (-sleepNanos > 1_000_000_000L) {
                    nextTick = System.nanoTime();
                }
            }
        }
    }

    private int produceOne(Connection connection, int criticalPercent) throws SQLException {
        ThreadLocalRandom random = ThreadLocalRandom.current();
        boolean critical = random.nextInt(100) < criticalPercent;
        int priority = critical ? 100 : 0;
        int buyerId = random.nextInt(1, 250_001);
        int shopId = random.nextInt(1, 10_001);
        int itemId = random.nextInt(1, 250_001);
        int pvzId = random.nextInt(1, 301);
        double orderTotal = critical
                ? random.nextDouble(20_000.0, 80_000.0)
                : random.nextDouble(500.0, 12_000.0);
        String eventType = critical ? "EXPENSIVE_ORDER_CREATED" : "ORDER_CREATED";
        String taskType = critical ? "CHECK_EXPENSIVE_ORDER_AND_DELIVERY" : "PROCESS_ORDER_DELIVERY";

        connection.setAutoCommit(false);
        try {
            long eventId = insertMarketplaceEvent(
                    connection,
                    buyerId,
                    shopId,
                    itemId,
                    pvzId,
                    orderTotal,
                    eventType
            );
            long taskId = insertTask(connection, eventId, buyerId, shopId, itemId, pvzId, orderTotal, priority, taskType);
            notifyWorkers(connection, taskId);

            connection.commit();
            return priority;
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    private long insertMarketplaceEvent(
            Connection connection,
            int buyerId,
            int shopId,
            int itemId,
            int pvzId,
            double orderTotal,
            String eventType
    ) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement("""
                INSERT INTO marketplace_events
                    (buyer_id, shop_id, item_id, pvz_id, order_total, event_type, description)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                RETURNING id
                """)) {
            statement.setInt(1, buyerId);
            statement.setInt(2, shopId);
            statement.setInt(3, itemId);
            statement.setInt(4, pvzId);
            statement.setDouble(5, orderTotal);
            statement.setString(6, eventType);
            statement.setString(7, "marketplace order event for background processing");
            try (ResultSet rs = statement.executeQuery()) {
                rs.next();
                return rs.getLong(1);
            }
        }
    }

    private long insertTask(
            Connection connection,
            long eventId,
            int buyerId,
            int shopId,
            int itemId,
            int pvzId,
            double orderTotal,
            int priority,
            String taskType
    ) throws SQLException {
        String payload = "{\"marketplaceEventId\":" + eventId
                + ",\"buyerId\":" + buyerId
                + ",\"shopId\":" + shopId
                + ",\"itemId\":" + itemId
                + ",\"pvzId\":" + pvzId
                + ",\"orderTotal\":" + String.format(Locale.US, "%.2f", orderTotal)
                + ",\"priority\":" + priority
                + "}";

        try (PreparedStatement statement = connection.prepareStatement("""
                INSERT INTO tasks (task_type, priority, payload)
                VALUES (?, ?, ?::jsonb)
                RETURNING id
                """)) {
            statement.setString(1, taskType);
            statement.setInt(2, priority);
            statement.setString(3, payload);
            try (ResultSet rs = statement.executeQuery()) {
                rs.next();
                return rs.getLong(1);
            }
        }
    }

    private void notifyWorkers(Connection connection, long taskId) throws SQLException {
        // PostgreSQL отправит NOTIFY только после commit. Это важно: worker не
        // проснется на задачу, которая потом могла бы откатиться rollback-ом.
        try (PreparedStatement statement = connection.prepareStatement("SELECT pg_notify(?, ?)")) {
            statement.setString(1, BrokerChannels.TASKS_READY);
            statement.setString(2, Long.toString(taskId));
            statement.execute();
        }
    }
}
