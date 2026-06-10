package controller;

import dal.WarrantyDAO;
import java.io.IOException;
import java.util.ArrayList;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.Warranty;

@WebServlet(name = "WarrantyServlet", urlPatterns = {"/warranty"})
public class WarrantyServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        WarrantyDAO dao = new WarrantyDAO();
        request.setAttribute("myWarrantyRequests", dao.getWarrantyRequestsByUser(account.getUserId()));

        request.getRequestDispatcher("/views/warranty.jsp").forward(request, response);
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

        String action = request.getParameter("action");
        WarrantyDAO dao = new WarrantyDAO();

        if ("search".equals(action)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));

                ArrayList<Warranty> warrantyProducts = dao.searchWarrantyByOrderId(orderId, account.getUserId());
                request.setAttribute("warrantyProducts", warrantyProducts);

                if (warrantyProducts.isEmpty()) {
                    request.setAttribute("error", "Không tìm thấy đơn hàng hoặc đơn hàng không thuộc tài khoản của bạn.");
                }

            } catch (Exception e) {
                request.setAttribute("error", "Order ID không hợp lệ.");
            }

            request.setAttribute("myWarrantyRequests", dao.getWarrantyRequestsByUser(account.getUserId()));
            request.getRequestDispatcher("/views/warranty.jsp").forward(request, response);
            return;
        }

        if ("create".equals(action)) {
            try {
                int orderDetailId = Integer.parseInt(request.getParameter("orderDetailId"));
                int productId = Integer.parseInt(request.getParameter("productId"));
                String requestContent = request.getParameter("requestContent");

                boolean success = dao.createWarrantyRequest(
                        orderDetailId,
                        account.getUserId(),
                        productId,
                        requestContent
                );

                if (success) {
                    request.setAttribute("message", "Gửi yêu cầu bảo hành thành công.");
                } else {
                    request.setAttribute("error", "Gửi yêu cầu bảo hành thất bại.");
                }

            } catch (Exception e) {
                request.setAttribute("error", "Dữ liệu gửi yêu cầu bảo hành không hợp lệ.");
            }

            request.setAttribute("myWarrantyRequests", dao.getWarrantyRequestsByUser(account.getUserId()));
            request.getRequestDispatcher("/views/warranty.jsp").forward(request, response);
        }
    }
}