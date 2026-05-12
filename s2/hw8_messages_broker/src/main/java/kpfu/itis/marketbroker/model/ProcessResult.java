package kpfu.itis.marketbroker.model;

/**
 * Результат обработки задачи.
 *
 * Нужен только для красивого логирования: worker печатает, завершилась задача,
 * ушла на retry или окончательно упала.
 */
public record ProcessResult(String statusForLog, int attempts, boolean retryScheduled) {
}
