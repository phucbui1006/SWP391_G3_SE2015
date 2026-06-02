package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    protected Connection connection;

    public DBContext() {
        try {
            String url = "jdbc:mysql://localhost:3306/db1";
            String username = "root";
            String password = "123456";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, username, password);
            System.out.println("Connect success!");
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Connect fail!");
            e.printStackTrace();
        }
    }

    public Connection getConnection() {
        return connection;
    }

}
