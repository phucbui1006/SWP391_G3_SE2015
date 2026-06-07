package controller;

import dal.RevenueDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Revenue;
import model.User;

@WebServlet(name = "RevenueServlet", urlPatterns = {"/revenue"})
public class RevenueServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        loadRevenuePage(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("export".equals(action)) {
            exportRevenue(request, response);
        } else {
            loadRevenuePage(request, response);
        }
    }

    private boolean checkAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return false;
        }

        String role = account.getRoleName();
        if (role == null || !role.equalsIgnoreCase("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return false;
        }

        return true;
    }

    private void loadRevenuePage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAdmin(request, response)) {
            return;
        }

        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");
        String paymentMethod = request.getParameter("paymentMethod");
        String paymentStatus = request.getParameter("paymentStatus");

        RevenueDAO dao = new RevenueDAO();

        ArrayList<Revenue> revenueList = dao.getRevenueList(fromDate, toDate, paymentMethod, paymentStatus);

        request.setAttribute("revenueList", revenueList);
        request.setAttribute("totalOrders", dao.getTotalOrders(fromDate, toDate, paymentMethod, paymentStatus));
        request.setAttribute("totalRevenue", dao.getTotalRevenue(fromDate, toDate, paymentMethod, paymentStatus));
        request.setAttribute("totalProductsSold", dao.getTotalProductsSold(fromDate, toDate, paymentMethod, paymentStatus));
        request.setAttribute("completedPayments", dao.getCompletedPayments(fromDate, toDate, paymentMethod, paymentStatus));

        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);
        request.setAttribute("paymentMethod", paymentMethod);
        request.setAttribute("paymentStatus", paymentStatus);

        request.getRequestDispatcher("/views/revenue.jsp").forward(request, response);
    }

    private void exportRevenue(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        if (!checkAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");
        String paymentMethod = request.getParameter("paymentMethod");
        String paymentStatus = request.getParameter("paymentStatus");

        RevenueDAO dao = new RevenueDAO();
        ArrayList<Revenue> list = dao.getRevenueList(fromDate, toDate, paymentMethod, paymentStatus);

        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=revenue_report.csv");

        PrintWriter out = response.getWriter();

        out.println("Order ID,User ID,Order Date,Payment Method,Payment Status,Total Amount");

        for (Revenue r : list) {
            out.println(
                    r.getOrderId() + ","
                    + r.getUserId() + ","
                    + r.getOrderDate() + ","
                    + r.getPaymentMethod() + ","
                    + r.getPaymentStatus() + ","
                    + r.getTotalAmount()
            );
        }

        out.flush();
        out.close();
    }
}