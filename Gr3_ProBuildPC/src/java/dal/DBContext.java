package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Proxy;

public class DBContext {

    private static final ThreadLocal<Connection> REQUEST_CONNECTION = new ThreadLocal<>();
    protected final Connection connection;

    public DBContext() {
        connection = createConnectionProxy();
    }

    private static Connection openConnection() throws SQLException {
        try {
            String url = getConfig("DB_URL", "jdbc:mysql://localhost:3306/db1");
            String username = getConfig("DB_USERNAME", "root");
            String password = getConfig("DB_PASSWORD", "123456");
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(url, username, password);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Connector/J driver is not available.", e);
        }
    }

    private static Connection currentConnection() throws SQLException {
        Connection current = REQUEST_CONNECTION.get();
        if (current == null || current.isClosed()) {
            current = openConnection();
            REQUEST_CONNECTION.set(current);
        }
        return current;
    }

    private static Connection createConnectionProxy() {
        return (Connection) Proxy.newProxyInstance(
                DBContext.class.getClassLoader(),
                new Class<?>[]{Connection.class},
                (proxy, method, args) -> {
                    if ("close".equals(method.getName())) {
                        closeRequestConnection();
                        return null;
                    }
                    if ("isClosed".equals(method.getName())) {
                        Connection current = REQUEST_CONNECTION.get();
                        return current == null || current.isClosed();
                    }
                    if ("toString".equals(method.getName())) {
                        return "RequestScopedConnectionProxy";
                    }
                    if ("hashCode".equals(method.getName())) {
                        return System.identityHashCode(proxy);
                    }
                    if ("equals".equals(method.getName())) {
                        return proxy == args[0];
                    }

                    try {
                        return method.invoke(currentConnection(), args);
                    } catch (InvocationTargetException e) {
                        throw e.getCause();
                    }
                }
        );
    }

    public Connection getConnection() {
        return connection;
    }

    public static void closeRequestConnection() {
        Connection current = REQUEST_CONNECTION.get();
        REQUEST_CONNECTION.remove();

        if (current == null) {
            return;
        }

        try {
            if (!current.getAutoCommit()) {
                current.rollback();
                current.setAutoCommit(true);
            }
        } catch (SQLException e) {
            // The connection may already be broken; closing it is still required.
        }

        try {
            current.close();
        } catch (SQLException e) {
            // Nothing else can be done during request cleanup.
        }
    }

    private static String getConfig(String name, String defaultValue) {
        String value = System.getProperty(name);
        if (value == null || value.isBlank()) {
            value = System.getenv(name);
        }
        return value == null || value.isBlank() ? defaultValue : value;
    }

}
