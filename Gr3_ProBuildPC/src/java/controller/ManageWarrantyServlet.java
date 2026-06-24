package controller;

import dal.WarrantyDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;
import model.User;
import model.Warranty;

@WebServlet(name = "ManageWarrantyServlet", urlPatterns = {"/ManageWarranty", "/manage-warranty"})
public class ManageWarrantyServlet extends HttpServlet {

    private final WarrantyDAO warrantyDAO = new WarrantyDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User account = session != null ? (User) session.getAttribute("account") : null;

        // Role-based access validation
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String roleName = account.getRoleName();
        if (roleName != null) {
            roleName = roleName.trim().toUpperCase();
        } else {
            roleName = "";
        }

        if (!"ADMIN".equals(roleName) && !"EMPLOYEE".equals(roleName)) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return;
        }

        // Search & Filter Parameters
        String search = request.getParameter("search");
        if (search == null) {
            search = request.getParameter("searchQuery");
        }
        if (search == null) {
            search = "";
        }

        String statusFilterRaw = request.getParameter("statusFilter");
        Integer statusFilterId = null;
        if (statusFilterRaw != null && !statusFilterRaw.trim().isEmpty()) {
            try {
                statusFilterId = Integer.parseInt(statusFilterRaw);
            } catch (NumberFormatException e) {
                // ignore
            }
        }

        List<Warranty> warrantyList = warrantyDAO.getAllWarranties(search, statusFilterId);
        
        request.setAttribute("warrantyList", warrantyList);
        request.setAttribute("searchQuery", search.trim());
        request.setAttribute("statusFilterId", statusFilterId);

        String action = request.getParameter("action");
        if ("viewCondition".equalsIgnoreCase(action)) {
            String orderDetailIdRaw = request.getParameter("orderDetailId");
            if (orderDetailIdRaw != null && !orderDetailIdRaw.trim().isEmpty()) {
                try {
                    int orderDetailId = Integer.parseInt(orderDetailIdRaw);
                    Warranty condItem = warrantyDAO.getProductWarrantyCondition(orderDetailId);
                    if (condItem != null) {
                        List<Warranty> condHistory = warrantyDAO.getWarrantyHistoryByOrderDetailId(orderDetailId);
                        request.setAttribute("condItem", condItem);
                        request.setAttribute("condHistory", condHistory);
                    }
                } catch (NumberFormatException e) {
                    // ignore
                }
            }
        } else if ("edit".equalsIgnoreCase(action) && "EMPLOYEE".equals(roleName)) {
            String warrantyIdRaw = request.getParameter("warrantyId");
            if (warrantyIdRaw != null && !warrantyIdRaw.trim().isEmpty()) {
                try {
                    int warrantyId = Integer.parseInt(warrantyIdRaw);
                    Warranty editWarranty = null;
                    for (Warranty w : warrantyList) {
                        if (w.getWarrantyId() == warrantyId) {
                            editWarranty = w;
                            break;
                        }
                    }
                    if (editWarranty != null) {
                        request.setAttribute("editWarranty", editWarranty);
                    }
                } catch (NumberFormatException e) {
                    // ignore
                }
            }
        }
        
        request.getRequestDispatcher("/views/manage-warranty.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User account = session != null ? (User) session.getAttribute("account") : null;

        // Ensure user is logged in
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String roleName = account.getRoleName();
        if (roleName != null) {
            roleName = roleName.trim().toUpperCase();
        } else {
            roleName = "";
        }

        // Only EMPLOYEE is allowed to perform POST actions (updates)
        if (!"EMPLOYEE".equals(roleName)) {
            session.setAttribute("errorMsg", "Chỉ nhân viên (EMPLOYEE) mới có quyền cập nhật trạng thái bảo hành!");
            response.sendRedirect(request.getContextPath() + "/ManageWarranty");
            return;
        }

        String warrantyIdRaw = request.getParameter("warrantyId");
        String statusIdRaw = request.getParameter("statusId");
        String search = request.getParameter("search");
        String statusFilter = request.getParameter("statusFilter");
        if (search == null) {
            search = "";
        }
        if (statusFilter == null) {
            statusFilter = "";
        }

        if (warrantyIdRaw == null || statusIdRaw == null) {
            session.setAttribute("errorMsg", "Dữ liệu cập nhật không đầy đủ!");
            response.sendRedirect(request.getContextPath() + "/ManageWarranty?search=" + java.net.URLEncoder.encode(search, "UTF-8") + "&statusFilter=" + statusFilter);
            return;
        }

        try {
            int warrantyId = Integer.parseInt(warrantyIdRaw);
            int statusId = Integer.parseInt(statusIdRaw);
            
            boolean success = warrantyDAO.updateWarrantyStatus(warrantyId, statusId);
            if (success) {
                session.setAttribute("successMsg", "Cập nhật yêu cầu bảo hành #" + warrantyId + " thành công!");
            } else {
                session.setAttribute("errorMsg", "Không thể cập nhật yêu cầu bảo hành!");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMsg", "Dữ liệu mã yêu cầu hoặc trạng thái không hợp lệ!");
        }

        response.sendRedirect(request.getContextPath() + "/ManageWarranty?search=" + java.net.URLEncoder.encode(search, "UTF-8") + "&statusFilter=" + statusFilter);
    }
}
