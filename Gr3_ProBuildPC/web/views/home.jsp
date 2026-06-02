<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>

<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect("login");
        return;
    }

    String role = "";

    switch (user.getRoleId()) {
        case 1:
            role = "ADMIN";
            break;

        case 2:
            role = "CUSTOMER";
            break;

        case 3:
            role = "EMPLOYEE";
            break;

        case 4:
            role = "TRANSPORT";
            break;

        default:
            role = "UNKNOWN";
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Home Page</title>

        <style>

            *{
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body{
                font-family: Arial, sans-serif;
                background-color: #f5f5f5;
            }

            .container{
                width: 90%;
                margin: 50px auto;
            }

            .card{
                background: white;
                padding: 40px;
                border-radius: 10px;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
            }

            h1{
                color: red;
                margin-bottom: 20px;
            }

            h2, h3{
                margin-bottom: 15px;
            }

            .logout-btn{
                display: inline-block;
                margin-top: 20px;
                padding: 12px 20px;
                background: red;
                color: white;
                text-decoration: none;
                border-radius: 5px;
            }

            .logout-btn:hover{
                background: darkred;
            }

        </style>
    </head>

    <body>

        <div class="container">

            <div class="card">

                <h1>WELCOME TO E-TECH</h1>

                <h2>
                    Hello:
                    <%= user.getFullName()%>
                </h2>

                <h3>
                    Email:
                    <%= user.getEmail()%>
                </h3>

                <h3>
                    Role:
                    <%= role%>
                </h3>

                <h3>
                    Status:
                    <%= user.getStatus()%>
                </h3>

                <a href="logout" class="logout-btn">
                    Logout
                </a>

            </div>

        </div>

    </body>
</html>