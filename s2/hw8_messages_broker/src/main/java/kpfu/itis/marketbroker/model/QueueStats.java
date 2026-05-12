package kpfu.itis.marketbroker.model;

/**
 * Снимок состояния очереди для monitor-а.
 */
public record QueueStats(long ready, long running, long completed, long failed, double readyLagSeconds) {
}
