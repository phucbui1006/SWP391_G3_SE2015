package controller;

import dal.BatchDAO;
import dal.BatchItemDAO;
import dal.ProductDAO;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Batch;
import model.BatchItem;
import model.Product;
import model.User;

@WebServlet(name = "BatchServlet", urlPatterns = {"/BatchServlet"})
public class BatchServlet extends HttpServlet {

    private BatchDAO batchDAO;
    private BatchItemDAO batchItemDAO;
    private ProductDAO productDAO;

    @Override
    public void init() {
        batchDAO = new BatchDAO();
        batchItemDAO = new BatchItemDAO();
        productDAO = new ProductDAO();
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return false;
        }

        User account = (User) session.getAttribute("account");

        String roleName = account.getRoleName();

        if (roleName == null || !"ADMIN".equalsIgnoreCase(roleName.trim())) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return false;
        }

        return true;
    }

    private void loadCommonData(HttpServletRequest request) {
        List<Batch> batches = batchDAO.getAllBatches();
        List<Product> products = productDAO.getAllProducts();

        request.setAttribute("batches", batches);
        request.setAttribute("products", products);
    }

    private void setSuccessMessage(HttpServletRequest request) {
        String success = request.getParameter("success");

        if (success == null) {
            return;
        }

        switch (success) {
            case "add":
                request.setAttribute("message", "Thêm lô hàng thành công.");
                break;
            case "update":
                request.setAttribute("message", "Cập nhật lô hàng thành công.");
                break;
            default:
                break;
        }
    }

    private void forwardToBatchPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        loadCommonData(request);

        /*
            Nếu batch.jsp nằm trong thư mục admin thì sửa thành:
            request.getRequestDispatcher("/admin/batch.jsp").forward(request, response);
        */
        request.getRequestDispatcher("/views/batch.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        if (!isAdmin(request, response)) {
            return;
        }

        String action = request.getParameter("action");

        try {
            setSuccessMessage(request);

            if (action == null || action.trim().isEmpty()) {
                forwardToBatchPage(request, response);
                return;
            }

            switch (action) {
                case "viewDetail": {
                    int batchId = Integer.parseInt(request.getParameter("batchId"));

                    List<BatchItem> batchItems = batchItemDAO.getItemsByBatchId(batchId);

                    request.setAttribute("selectedBatchId", batchId);
                    request.setAttribute("batchItems", batchItems);

                    forwardToBatchPage(request, response);
                    break;
                }

                case "editBatch": {
                    int batchId = Integer.parseInt(request.getParameter("batchId"));

                    Batch editBatch = batchDAO.getBatchById(batchId);

                    if (editBatch == null) {
                        request.setAttribute("error", "Không tìm thấy lô hàng cần sửa.");
                    } else {
                        request.setAttribute("editBatch", editBatch);
                    }

                    forwardToBatchPage(request, response);
                    break;
                }

                default:
                    response.sendRedirect(request.getContextPath() + "/BatchServlet");
                    break;
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Mã lô hàng không hợp lệ.");
            forwardToBatchPage(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải dữ liệu lô hàng.");
            forwardToBatchPage(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        if (!isAdmin(request, response)) {
            return;
        }

        String action = request.getParameter("action");

        try {
            if (action == null || action.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/BatchServlet");
                return;
            }

            switch (action) {
                case "addBatch": {
                    String batchName = request.getParameter("batchName");
                    String dateRaw = request.getParameter("date");

                    if (batchName == null || batchName.trim().isEmpty()
                            || dateRaw == null || dateRaw.trim().isEmpty()) {

                        request.setAttribute("error", "Vui lòng nhập đầy đủ tên lô hàng và ngày nhập.");
                        forwardToBatchPage(request, response);
                        return;
                    }

                    Date inputDate = Date.valueOf(dateRaw);
                    Date currentDate = Date.valueOf(java.time.LocalDate.now());
                    
                    if (inputDate.after(currentDate)) {
                        request.setAttribute("error", "Ngày nhập lô hàng không hợp lệ.");
                        forwardToBatchPage(request, response);
                        return;
                    }

                    Batch batch = new Batch();
                    batch.setBatchName(batchName.trim());
                    batch.setDate(inputDate);

                    boolean success = batchDAO.addBatch(batch);

                    if (success) {
                        response.sendRedirect(request.getContextPath() + "/BatchServlet?success=add");
                    } else {
                        request.setAttribute("error", "Thêm lô hàng thất bại.");
                        forwardToBatchPage(request, response);
                    }

                    break;
                }

                case "updateBatch": {
                    int batchId = Integer.parseInt(request.getParameter("batchId"));
                    String batchName = request.getParameter("batchName");
                    String dateRaw = request.getParameter("date");

                    if (batchName == null || batchName.trim().isEmpty()
                            || dateRaw == null || dateRaw.trim().isEmpty()) {

                        request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin lô hàng.");
                        forwardToBatchPage(request, response);
                        return;
                    }

                    Date inputDate = Date.valueOf(dateRaw);
                    Date currentDate = Date.valueOf(java.time.LocalDate.now());
                    
                    if (inputDate.after(currentDate)) {
                        request.setAttribute("error", "Ngày nhập lô hàng không được lớn hơn ngày hiện tại.");
                        forwardToBatchPage(request, response);
                        return;
                    }

                    Batch batch = new Batch();
                    batch.setBatchId(batchId);
                    batch.setBatchName(batchName.trim());
                    batch.setDate(inputDate);

                    boolean success = batchDAO.updateBatch(batch);

                    if (success) {
                        response.sendRedirect(request.getContextPath() + "/BatchServlet?success=update");
                    } else {
                        request.setAttribute("error", "Cập nhật lô hàng thất bại.");
                        forwardToBatchPage(request, response);
                    }

                    break;
                }

                default:
                    response.sendRedirect(request.getContextPath() + "/BatchServlet");
                    break;
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Dữ liệu số không hợp lệ.");
            forwardToBatchPage(request, response);

        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            request.setAttribute("error", "Ngày nhập không hợp lệ.");
            forwardToBatchPage(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi xử lý lô hàng.");
            forwardToBatchPage(request, response);
        }
    }
}