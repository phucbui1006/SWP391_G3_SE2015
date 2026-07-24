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
import java.util.ArrayList;
import model.Batch;
import model.BatchItem;
import model.Product;

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

    private static final int PAGE_SIZE = 5;

    private void loadCommonData(HttpServletRequest request) {
        String pageRaw = request.getParameter("page");
        int currentPage = 1;
        try {
            if (pageRaw != null && !pageRaw.trim().isEmpty()) {
                currentPage = Integer.parseInt(pageRaw);
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }

        List<Batch> allBatches = batchDAO.getAllBatches();
        int totalBatches = allBatches.size();
        int totalPages = totalBatches == 0 ? 1 : (int) Math.ceil((double) totalBatches / PAGE_SIZE);

        if (currentPage < 1 || currentPage > totalPages) {
            currentPage = 1;
        }

        int offset = (currentPage - 1) * PAGE_SIZE;
        int toIndex = Math.min(offset + PAGE_SIZE, totalBatches);
        List<Batch> batches = new ArrayList<>(allBatches.subList(offset, toIndex));
        List<Product> products = productDAO.getAllProducts();

        int startItem = totalBatches == 0 ? 0 : offset + 1;
        int endItem = Math.min(currentPage * PAGE_SIZE, totalBatches);

        request.setAttribute("batches", batches);
        request.setAttribute("allBatches", allBatches);
        request.setAttribute("products", products);
        
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalBatches", totalBatches);
        request.setAttribute("startItem", startItem);
        request.setAttribute("endItem", endItem);
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
            case "updateBatch":
                request.setAttribute("message", "Cập nhật thông tin lô hàng thành công.");
                break;
            case "updateItem":
                request.setAttribute("message", "Cập nhật sản phẩm trong lô thành công.");
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

        String action = request.getParameter("action");

        try {
            setSuccessMessage(request);

            HttpSession session = request.getSession(false);
            if (session != null) {
                String batchError = (String) session.getAttribute("batchError");
                if (batchError != null) {
                    request.setAttribute("error", batchError);
                    session.removeAttribute("batchError");
                }
                String enteredBatchName = (String) session.getAttribute("enteredBatchName");
                if (enteredBatchName != null) {
                    request.setAttribute("enteredBatchName", enteredBatchName);
                    session.removeAttribute("enteredBatchName");
                }
                String enteredDate = (String) session.getAttribute("enteredDate");
                if (enteredDate != null) {
                    request.setAttribute("enteredDate", enteredDate);
                    session.removeAttribute("enteredDate");
                }
            }

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

                    Date inputDate = Date.valueOf(dateRaw);

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
                    String page = request.getParameter("page");
                    String pageParam = (page != null && !page.trim().isEmpty()) ? "?page=" + page + "&" : "?";

                    Date inputDate = Date.valueOf(dateRaw);

                    boolean success = batchDAO.updateBatch(batchId, batchName.trim(), inputDate);

                    if (success) {
                        response.sendRedirect(request.getContextPath() + "/BatchServlet" + pageParam + "success=updateBatch");
                    } else {
                        request.setAttribute("error", "Cập nhật thông tin lô hàng thất bại.");
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
