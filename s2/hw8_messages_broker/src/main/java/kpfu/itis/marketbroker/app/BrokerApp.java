package kpfu.itis.marketbroker.app;

import kpfu.itis.marketbroker.config.AppConfig;
import kpfu.itis.marketbroker.monitor.QueueMonitor;
import kpfu.itis.marketbroker.producer.MarketplaceProducer;
import kpfu.itis.marketbroker.worker.TaskWorker;

import java.util.Locale;

/**
 * Entry point приложения.
 *
 * Один и тот же jar запускается в разных docker-compose сервисах. Конкретная
 * роль выбирается через переменную окружения ROLE:
 * producer - создает события маркетплейса и задачи;
 * worker   - забирает и обрабатывает задачи;
 * monitor  - печатает лаг очереди и throughput.
 */
public final class BrokerApp {
    private BrokerApp() {
    }

    public static void main(String[] args) throws Exception {
        String role = args.length > 0 ? args[0] : AppConfig.env("ROLE", "producer");
        switch (role.toLowerCase(Locale.ROOT)) {
            case "producer" -> new MarketplaceProducer().run();
            case "worker" -> new TaskWorker().run();
            case "monitor" -> new QueueMonitor().run();
            default -> throw new IllegalArgumentException("Unknown ROLE: " + role);
        }
    }
}
