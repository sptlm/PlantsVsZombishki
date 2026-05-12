package kpfu.itis.marketbroker.monitor;

import kpfu.itis.marketbroker.config.AppConfig;
import kpfu.itis.marketbroker.db.Database;
import kpfu.itis.marketbroker.model.QueueStats;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Locale;

/**
 * Monitor только читает агрегаты из БД и печатает их в лог.
 *
 * Он показывает, растет ли очередь, какой лаг у старейшей Ready-задачи и сколько
 * задач в секунду успевают завершить оба worker-а вместе.
 */
public final class QueueMonitor {
    public void run() throws Exception {
        int intervalSeconds = AppConfig.intEnv("MONITOR_INTERVAL_SECONDS", 5);
        long previousCompleted = -1;
        long previousTime = System.nanoTime();

        try (Connection connection = Database.openConnection("monitor")) {
            System.out.printf("monitor started: interval=%ds%n", intervalSeconds);
            while (true) {
                QueueStats stats = loadStats(connection);
                long now = System.nanoTime();
                double throughput = 0.0;
                if (previousCompleted >= 0) {
                    double elapsed = (now - previousTime) / 1_000_000_000.0;
                    throughput = (stats.completed() - previousCompleted) / elapsed;
                }
                previousCompleted = stats.completed();
                previousTime = now;

                System.out.printf(
                        "monitor ready=%d running=%d completed=%d failed=%d lag_oldest_ready_s=%.2f throughput=%.2f tasks/s waits=[%s]%n",
                        stats.ready(),
                        stats.running(),
                        stats.completed(),
                        stats.failed(),
                        stats.readyLagSeconds(),
                        throughput,
                        loadPriorityWaits(connection)
                );

                Thread.sleep(intervalSeconds * 1_000L);
            }
        }
    }

    private QueueStats loadStats(Connection connection) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement("""
                SELECT
                    count(*) FILTER (WHERE status = 'Ready') AS ready,
                    count(*) FILTER (WHERE status = 'Running') AS running,
                    count(*) FILTER (WHERE status = 'Completed') AS completed,
                    count(*) FILTER (WHERE status = 'Failed') AS failed,
                    COALESCE(EXTRACT(EPOCH FROM clock_timestamp() - MIN(created_at) FILTER (WHERE status = 'Ready')), 0) AS ready_lag_seconds
                FROM tasks
                """);
             ResultSet rs = statement.executeQuery()) {
            rs.next();
            return new QueueStats(
                    rs.getLong("ready"),
                    rs.getLong("running"),
                    rs.getLong("completed"),
                    rs.getLong("failed"),
                    rs.getDouble("ready_lag_seconds")
            );
        }
    }

    private String loadPriorityWaits(Connection connection) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement("""
                SELECT
                    priority,
                    count(*) FILTER (WHERE status = 'Completed') AS completed,
                    COALESCE(AVG(EXTRACT(EPOCH FROM started_at - created_at)) FILTER (WHERE started_at IS NOT NULL), 0) AS avg_wait_seconds
                FROM tasks
                GROUP BY priority
                ORDER BY priority DESC
                """);
             ResultSet rs = statement.executeQuery()) {
            StringBuilder builder = new StringBuilder();
            while (rs.next()) {
                if (!builder.isEmpty()) {
                    builder.append("; ");
                }
                builder.append("p")
                        .append(rs.getInt("priority"))
                        .append(" completed=")
                        .append(rs.getLong("completed"))
                        .append(" avg_wait_s=")
                        .append(String.format(Locale.US, "%.3f", rs.getDouble("avg_wait_seconds")));
            }
            return builder.toString();
        }
    }
}
