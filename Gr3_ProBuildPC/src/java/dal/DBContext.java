package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    protected Connection connection;

    public DBContext() {
        try {
            String url = getConfig("DB_URL", "jdbc:mysql://localhost:3306/db1");
            String username = getConfig("DB_USERNAME", "root");
            String password = getConfig("DB_PASSWORD", "123456");
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, username, password);
        } catch (ClassNotFoundException | SQLException e) {
            throw new IllegalStateException(
                    "Cannot connect to the database. Check that MySQL is running, "
                    + "database 'db1' exists, the MySQL Connector/J JAR is deployed, "
                    + "and DB_URL/DB_USERNAME/DB_PASSWORD are correct.",
                    e
            );
        }
    }

    public Connection getConnection() {
        return connection;
    }

    private static String getConfig(String name, String defaultValue) {
        String value = System.getProperty(name);
        if (value == null || value.isBlank()) {
            value = System.getenv(name);
        }
        return value == null || value.isBlank() ? defaultValue : value;
    }

}
