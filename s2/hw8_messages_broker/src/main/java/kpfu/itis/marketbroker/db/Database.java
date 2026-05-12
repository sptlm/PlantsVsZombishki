package kpfu.itis.marketbroker.db;

import kpfu.itis.marketbroker.config.AppConfig;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Создает JDBC-соединения с PostgreSQL.
 *
 * Метод делает несколько попыток подключения, потому что Java-сервисы в compose
 * могут стартовать сразу после healthcheck базы, а сеть/контейнер еще пару
 * секунд стабилизируются.
 */
public final class Database {
    private Database() {
    }

    public static Connection openConnection(String applicationName) throws Exception {
        String url = AppConfig.env("DB_URL", "jdbc:postgresql://localhost:5548/marketplace_queue");
        Properties properties = new Properties();
        properties.setProperty("user", AppConfig.env("DB_USER", "admin"));
        properties.setProperty("password", AppConfig.env("DB_PASSWORD", "admin_pass"));
        properties.setProperty("ApplicationName", "hw8-" + applicationName);

        SQLException lastError = null;
        for (int attempt = 1; attempt <= 30; attempt++) {
            try {
                return DriverManager.getConnection(url, properties);
            } catch (SQLException e) {
                lastError = e;
                Thread.sleep(1_000L);
            }
        }
        throw lastError;
    }
}
