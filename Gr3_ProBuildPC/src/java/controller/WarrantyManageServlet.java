package controller;

import dal.WarrantyDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "WarrantyManageServlet", urlPatterns = {"/warranty-manage"})
public class WarrantyManageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String role = account.getRoleName();
        if (role == null || 
            (!role.equalsIgnoreCase("ADMIN") && !role.equalsIgnoreCase("EMPLOYEE"))) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return;
        }

        WarrantyDAO dao = new WarrantyDAO();
        request.setAttribute("warrantyList", dao.getAllWarrantyRequests());

        request.getRequestDispatcher("/views/warranty-manage.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String role = account.getRoleName();
        if (role == null || 
            (!role.equalsIgnoreCase("ADMIN") && !role.equalsIgnoreCase("EMPLOYEE"))) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return;
        }

        try {
            int warrantyId = Integer.parseInt(request.getParameter("warrantyId"));
            int statusId = Integer.parseInt(request.getParameter("statusId"));

            WarrantyDAO dao = new WarrantyDAO();
            dao.updateWarrantyStatus(warrantyId, statusId);

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/warranty-manage");
    }
}