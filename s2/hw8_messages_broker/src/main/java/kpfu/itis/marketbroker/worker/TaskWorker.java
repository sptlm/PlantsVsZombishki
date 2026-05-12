package kpfu.itis.marketbroker.worker;

import kpfu.itis.marketbroker.config.AppConfig;
import kpfu.itis.marketbroker.db.BrokerChannels;
import kpfu.itis.marketbroker.db.Database;
import kpfu.itis.marketbroker.model.ProcessResult;
import kpfu.itis.marketbroker.model.Task;
import org.postgresql.PGConnection;
import org.postgresql.PGNotification;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.time.Duration;
import java.time.Instant;
import java.util.Random;
import java.util.concurrent.ThreadLocalRandom;

/**
 * Worker - независимый процесс, который конкурирует за задачи с другими worker-ами.
 */
public final class TaskWorker {
    public void run() throws Exception {
        String workerId = AppConfig.env("WORKER_ID", "worker-" + ThreadLocalRandom.current().nextInt(10_000));
        int failPercent = AppConfig.intEnv("WORKER_FAIL_PERCENT", 5);
        int baseBackoffSeconds = AppConfig.intEnv("WORKER_BACKOFF_SECONDS", 300);
        int listenTimeoutMillis = AppConfig.intEnv("WORKER_LISTEN_TIMEOUT_MS", 60_000);
        Random random = new Random();
        long processed = 0;

        try (Connection workerConnection = Database.openConnection(workerId);
             Connection listenConnection = Database.openConnection(workerId + "-listener")) {
            try (Statement statement = listenConnection.createStatement()) {
                statement.execute("LISTEN " + BrokerChannels.TASKS_READY);
            }
            PGConnection pgConnection = listenConnection.unwrap(PGConnection.class);
            System.out.printf("%s started: fail=%d%% backoffBase=%ds%n", workerId, failPercent, baseBackoffSeconds);

            while (true) {
                Task task;
                boolean hadWork = false;
                while ((task = claimTask(workerConnection, workerId)) != null) {
                    hadWork = true;
                    processed++;
                    ProcessResult result = processTask(workerConnection, task, workerId, failPercent, baseBackoffSeconds, random);
                    logIfInteresting(workerId, processed, task, result);
                }

                if (!hadWork) {
                    waitForNotify(pgConnection, workerId, listenTimeoutMillis);
                }
            }
        }
    }

    private Task claimTask(Connection connection, String workerId) throws SQLException {
        connection.setAutoCommit(false);
        try (PreparedStatement statement = connection.prepareStatement("""
                WITH candidate AS (
                    SELECT id
                    FROM tasks
                    WHERE status = 'Ready'
                      AND scheduled_at <= clock_timestamp()
                    ORDER BY priority DESC, scheduled_at, created_at, id
                    FOR UPDATE SKIP LOCKED
                    LIMIT 1
                )
                UPDATE tasks AS t
                SET status = 'Running',
                    started_at = clock_timestamp(),
                    updated_at = clock_timestamp(),
                    locked_by = ?
                FROM candidate
                WHERE t.id = candidate.id
                RETURNING t.id, t.task_type, t.priority, t.payload::text, t.attempts, t.max_attempts, t.created_at
                """)) {
            statement.setString(1, workerId);
            try (ResultSet rs = statement.executeQuery()) {
                if (!rs.next()) {
                    connection.rollback();
                    return null;
                }

                Task task = new Task(
                        rs.getLong("id"),
                        rs.getString("task_type"),
                        rs.getInt("priority"),
                        rs.getString("payload"),
                        rs.getInt("attempts"),
                        rs.getInt("max_attempts"),
                        rs.getTimestamp("created_at").toInstant()
                );
                connection.commit();
                return task;
            }
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    private ProcessResult processTask(
            Connection connection,
            Task task,
            String workerId,
            int failPercent,
            int baseBackoffSeconds,
            Random random
    ) throws Exception {
        Thread.sleep(processingMillis(task.priority()));
        boolean failed = random.nextInt(100) < failPercent;
        if (!failed) {
            completeTask(connection, task.id(), workerId);
            return new ProcessResult("Completed", task.attempts(), false);
        }

        int nextAttempts = task.attempts() + 1;
        if (nextAttempts >= task.maxAttempts()) {
            markFailed(connection, task.id(), workerId, nextAttempts, "max attempts reached");
            return new ProcessResult("Failed", nextAttempts, false);
        }

        int backoffSeconds = exponentialBackoffSeconds(baseBackoffSeconds, nextAttempts);
        retryLater(connection, task.id(), workerId, nextAttempts, backoffSeconds);
        return new ProcessResult("Retry in " + backoffSeconds + "s", nextAttempts, true);
    }

    private long processingMillis(int priority) {
        ThreadLocalRandom random = ThreadLocalRandom.current();
        if (priority == 100) {
            return random.nextLong(
                    AppConfig.intEnv("WORKER_CRITICAL_MIN_MS", 20),
                    AppConfig.intEnv("WORKER_CRITICAL_MAX_MS", 40) + 1L
            );
        }
        return random.nextLong(
                AppConfig.intEnv("WORKER_NORMAL_MIN_MS", 50),
                AppConfig.intEnv("WORKER_NORMAL_MAX_MS", 100) + 1L
        );
    }

    private void completeTask(Connection connection, long taskId, String workerId) throws SQLException {
        updateFinalStatus(connection, taskId, workerId, "Completed", null, null);
    }

    private void retryLater(
            Connection connection,
            long taskId,
            String workerId,
            int attempts,
            int backoffSeconds
    ) throws SQLException {
        connection.setAutoCommit(false);
        try (PreparedStatement statement = connection.prepareStatement("""
                UPDATE tasks
                SET status = 'Ready',
                    attempts = ?,
                    scheduled_at = clock_timestamp() + make_interval(secs => ?),
                    updated_at = clock_timestamp(),
                    locked_by = NULL,
                    error_message = ?
                WHERE id = ?
                  AND locked_by = ?
                  AND status = 'Running'
                """)) {
            statement.setInt(1, attempts);
            statement.setInt(2, backoffSeconds);
            statement.setString(3, "transient marketplace processing failure, retry scheduled");
            statement.setLong(4, taskId);
            statement.setString(5, workerId);
            statement.executeUpdate();
            connection.commit();
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    private void markFailed(
            Connection connection,
            long taskId,
            String workerId,
            int attempts,
            String error
    ) throws SQLException {
        updateFinalStatus(connection, taskId, workerId, "Failed", attempts, error);
    }

    private void updateFinalStatus(
            Connection connection,
            long taskId,
            String workerId,
            String status,
            Integer attempts,
            String error
    ) throws SQLException {
        connection.setAutoCommit(false);
        try (PreparedStatement statement = connection.prepareStatement("""
                UPDATE tasks
                SET status = ?,
                    attempts = COALESCE(?, attempts),
                    completed_at = clock_timestamp(),
                    updated_at = clock_timestamp(),
                    locked_by = NULL,
                    error_message = ?
                WHERE id = ?
                  AND locked_by = ?
                  AND status = 'Running'
                """)) {
            statement.setString(1, status);
            if (attempts == null) {
                statement.setNull(2, Types.INTEGER);
            } else {
                statement.setInt(2, attempts);
            }
            statement.setString(3, error);
            statement.setLong(4, taskId);
            statement.setString(5, workerId);
            statement.executeUpdate();
            connection.commit();
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    private int exponentialBackoffSeconds(int baseBackoffSeconds, int attempts) {
        int shift = Math.min(Math.max(0, attempts - 1), 6);
        return baseBackoffSeconds * (1 << shift);
    }

    private void waitForNotify(PGConnection pgConnection, String workerId, int listenTimeoutMillis) throws SQLException {
        // Основной сценарий: producer делает pg_notify, и worker просыпается сразу.
        // Таймаут здесь не является рабочим polling-интервалом; это редкая страховка,
        // чтобы worker иногда перепроверял очередь, если соединение пережило сбой
        // или уведомление было пропущено во время рестарта.
        PGNotification[] notifications = pgConnection.getNotifications(listenTimeoutMillis);
        if (notifications != null && notifications.length > 0) {
            System.out.printf("%s woke up by NOTIFY count=%d%n", workerId, notifications.length);
        }
    }

    private void logIfInteresting(String workerId, long processed, Task task, ProcessResult result) {
        if (task.priority() == 100 || processed % 100 == 0 || result.retryScheduled()) {
            long waitMillis = Duration.between(task.createdAt(), Instant.now()).toMillis();
            System.out.printf(
                    "%s task=%d priority=%d type=%s result=%s attempts=%d wait_ms=%d processed=%d%n",
                    workerId,
                    task.id(),
                    task.priority(),
                    task.taskType(),
                    result.statusForLog(),
                    result.attempts(),
                    waitMillis,
                    processed
            );
        }
    }
}
