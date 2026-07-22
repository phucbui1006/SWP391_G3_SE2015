package controller;

import dal.WarrantyDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.User;
import model.Warranty;
import model.WarrantyRequest;

@WebServlet(name = "ManageWarrantyServlet", urlPatterns = {"/ManageWarranty", "/manage-warranty"})
public class ManageWarrantyServlet extends HttpServlet {

    private static final int PAGE_SIZE = 5;
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

        // Intercept search parameters (keyword, query, search, searchQuery)
        String search = request.getParameter("keyword");
        if (search == null) {
            search = request.getParameter("query");
        }
        if (search == null) {
            search = request.getParameter("search");
        }
        if (search == null) {
            search = request.getParameter("searchQuery");
        }
        if (search == null) {
            search = "";
        }

        String statusRaw = request.getParameter("statusId");
        if (statusRaw == null) {
            statusRaw = request.getParameter("statusFilter");
        }
        if (statusRaw == null) {
            statusRaw = request.getParameter("status");
        }
        Integer statusId = null;
        if (statusRaw != null && !statusRaw.trim().isEmpty()) {
            try {
                statusId = Integer.parseInt(statusRaw);
            } catch (NumberFormatException e) {
                // ignore
            }
        }

        int page = 1;
        String pageRaw = request.getParameter("page");
        if (pageRaw != null && !pageRaw.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageRaw.trim());
                if (page < 1) {
                    page = 1;
                }
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int totalWarranties = warrantyDAO.countAllWarrantyRequestsForAdmin(search, statusId);
        int totalPages = Math.max(1, (int) Math.ceil(totalWarranties / (double) PAGE_SIZE));
        if (page > totalPages) {
            page = totalPages;
        }

        List<WarrantyRequest> adminList = warrantyDAO.getAllWarrantyRequestsForAdmin(search, statusId, page, PAGE_SIZE);

        Integer selectedWarrantyId = null;
        String selRaw = request.getParameter("selectedWarrantyId");
        if (selRaw == null) {
            selRaw = request.getParameter("warrantyId");
        }
        if (selRaw != null && !selRaw.trim().isEmpty()) {
            try {
                selectedWarrantyId = Integer.parseInt(selRaw.trim());
            } catch (NumberFormatException e) {
                // ignore
            }
        }

        WarrantyRequest selectedWarranty = null;
        if (selectedWarrantyId != null) {
            for (WarrantyRequest w : adminList) {
                if (w.getWarrantyId() == selectedWarrantyId) {
                    selectedWarranty = w;
                    break;
                }
            }
            if (selectedWarranty == null) {
                selectedWarranty = warrantyDAO.getWarrantyRequestById(selectedWarrantyId);
            }
        }

        if (selectedWarranty == null && !adminList.isEmpty()) {
            selectedWarranty = adminList.get(0);
        }

        if (selectedWarranty != null) {
            Warranty condItem = warrantyDAO.getProductWarrantyCondition(selectedWarranty.getProductId(), selectedWarranty.getCustomerId());
            List<Warranty> condHistory = warrantyDAO.getWarrantyHistoryByProductAndCustomer(selectedWarranty.getProductId(), selectedWarranty.getCustomerId());
            request.setAttribute("condItem", condItem);
            request.setAttribute("condHistory", condHistory);
        }

        String action = request.getParameter("action");
        if ("viewCondition".equalsIgnoreCase(action)) {
            String productIdRaw = request.getParameter("productId");
            String customerIdRaw = request.getParameter("customerId");
            if (productIdRaw != null && !productIdRaw.trim().isEmpty()
                    && customerIdRaw != null && !customerIdRaw.trim().isEmpty()) {
                try {
                    int productId = Integer.parseInt(productIdRaw);
                    int customerId = Integer.parseInt(customerIdRaw);
                    Warranty condItem = warrantyDAO.getProductWarrantyCondition(productId, customerId);
                    if (condItem != null) {
                        List<Warranty> condHistory = warrantyDAO.getWarrantyHistoryByProductAndCustomer(productId, customerId);
                        request.setAttribute("condItem", condItem);
                        request.setAttribute("condHistory", condHistory);
                    }
                } catch (NumberFormatException e) {
                }
            }
        } else if ("edit".equalsIgnoreCase(action) && "EMPLOYEE".equals(roleName)) {
            String warrantyIdRaw = request.getParameter("warrantyId");
            if (warrantyIdRaw != null && !warrantyIdRaw.trim().isEmpty()) {
                try {
                    int warrantyId = Integer.parseInt(warrantyIdRaw);
                    WarrantyRequest editWarranty = null;
                    for (WarrantyRequest w : adminList) {
                        if (w.getWarrantyId() == warrantyId) {
                            editWarranty = w;
                            break;
                        }
                    }
                    if (editWarranty == null) {
                        editWarranty = warrantyDAO.getWarrantyRequestById(warrantyId);
                    }
                    if (editWarranty != null) {
                        request.setAttribute("editWarranty", editWarranty);
                    }
                } catch (NumberFormatException e) {
                    // ignore
                }
            }
        }

        request.setAttribute("adminWarrantyList", adminList);
        request.setAttribute("warrantyList", adminList);
        request.setAttribute("selectedWarranty", selectedWarranty);
        request.setAttribute("searchQuery", search.trim());
        request.setAttribute("keyword", search.trim());
        request.setAttribute("statusFilterId", statusId);
        request.setAttribute("selectedStatusId", statusId);
        request.setAttribute("page", page);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalWarranties", totalWarranties);

        request.getRequestDispatcher("/views/manage-warranty.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User account = session != null ? (User) session.getAttribute("account") : null;

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

        if (!"EMPLOYEE".equals(roleName)) {
            session.setAttribute("errorMsg", "Chỉ nhân viên (EMPLOYEE) mới có quyền cập nhật trạng thái bảo hành!");
            response.sendRedirect(request.getContextPath() + "/ManageWarranty");
            return;
        }

        String warrantyIdRaw = request.getParameter("warrantyId");
        String statusIdRaw = request.getParameter("statusId");
        String responseText = request.getParameter("response");
        String search = request.getParameter("search");
        if (search == null) {
            search = request.getParameter("keyword");
        }
        String statusFilter = request.getParameter("statusFilter");
        if (statusFilter == null) {
            statusFilter = request.getParameter("statusId");
        }
        String pageRaw = request.getParameter("page");
        String selectedWarrantyIdRaw = request.getParameter("selectedWarrantyId");
        if (selectedWarrantyIdRaw == null) {
            selectedWarrantyIdRaw = warrantyIdRaw;
        }

        if (search == null) {
            search = "";
        }
        if (statusFilter == null) {
            statusFilter = "";
        }

        if (warrantyIdRaw == null || statusIdRaw == null) {
            session.setAttribute("errorMsg", "Dữ liệu cập nhật không đầy đủ!");
            redirectBack(request, response, search, statusFilter, pageRaw, selectedWarrantyIdRaw);
            return;
        }

        try {
            int warrantyId = Integer.parseInt(warrantyIdRaw);
            int statusId = Integer.parseInt(statusIdRaw);
            if (statusId != 2 && statusId != 3) {
                session.setAttribute("errorMsg", "Trạng thái cập nhật phải là 'Từ chối' hoặc 'Chấp nhận'!");
                redirectBack(request, response, search, statusFilter, pageRaw, selectedWarrantyIdRaw);
                return;
            }
            if (responseText == null) {
                responseText = "";
            }

            boolean success = warrantyDAO.updateWarrantyStatus(warrantyId, statusId, responseText.trim());
            if (success) {
                session.setAttribute("successMsg", "Cập nhật yêu cầu bảo hành #" + warrantyId + " thành công!");
            } else {
                session.setAttribute("errorMsg", "Không thể cập nhật yêu cầu bảo hành!");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMsg", "Dữ liệu mã yêu cầu hoặc trạng thái không hợp lệ!");
        }

        redirectBack(request, response, search, statusFilter, pageRaw, selectedWarrantyIdRaw);
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response,
                              String search, String statusFilter, String pageRaw, String selectedWarrantyIdRaw)
            throws IOException {
        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/ManageWarranty?");
        redirectUrl.append("search=").append(java.net.URLEncoder.encode(search, "UTF-8"));
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            redirectUrl.append("&statusFilter=").append(statusFilter.trim());
        }
        if (pageRaw != null && !pageRaw.trim().isEmpty()) {
            redirectUrl.append("&page=").append(pageRaw.trim());
        }
        if (selectedWarrantyIdRaw != null && !selectedWarrantyIdRaw.trim().isEmpty()) {
            redirectUrl.append("&selectedWarrantyId=").append(selectedWarrantyIdRaw.trim());
        }
        response.sendRedirect(redirectUrl.toString());
    }
}
