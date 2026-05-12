package kpfu.itis.marketbroker.config;

/**
 * Маленький helper для чтения переменных окружения.
 *
 * Конфиг специально оставлен простым: в учебном проекте не нужен Spring или
 * отдельная библиотека конфигурации, достаточно env-переменных из docker-compose.
 */
public final class AppConfig {
    private AppConfig() {
    }

    public static String env(String name, String defaultValue) {
        String value = System.getenv(name);
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        return value;
    }

    public static int intEnv(String name, int defaultValue) {
        return Integer.parseInt(env(name, Integer.toString(defaultValue)));
    }
}
