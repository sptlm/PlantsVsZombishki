package kpfu.itis.marketbroker.model;

import java.time.Instant;

/**
 * Задача, которую worker забрал из таблицы tasks.
 *
 * Это не вся строка из БД, а только поля, нужные worker-у для обработки,
 * логирования и retry.
 */
public record Task(
        long id,
        String taskType,
        int priority,
        String payload,
        int attempts,
        int maxAttempts,
        Instant createdAt
) {
}
