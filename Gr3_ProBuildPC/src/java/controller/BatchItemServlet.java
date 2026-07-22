package controller;

import dal.BatchDAO;
import dal.BatchItemDAO;
import dal.ProductDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Batch;
import model.BatchItem;
import model.Product;

@WebServlet(name = "BatchItemServlet", urlPatterns = {"/BatchItemServlet"})
public class BatchItemServlet extends HttpServlet {

    private BatchDAO batchDAO;
    private BatchItemDAO batchItemDAO;
    private ProductDAO productDAO;

    @Override
    public void init() {
        batchDAO = new BatchDAO();
        batchItemDAO = new BatchItemDAO();
        productDAO = new ProductDAO();
    }

    private void loadCommonData(HttpServletRequest request) {
        List<Batch> batches = batchDAO.getAllBatches();
        List<Product> products = productDAO.getAllProducts();

        request.setAttribute("batches", batches);
        request.setAttribute("allBatches", batches);
        request.setAttribute("products", products);
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

    private void forwardWithBatchDetail(HttpServletRequest request,
                                        HttpServletResponse response,
                                        int batchId)
            throws ServletException, IOException {

        List<BatchItem> batchItems = batchItemDAO.getItemsByBatchId(batchId);

        request.setAttribute("selectedBatchId", batchId);
        request.setAttribute("batchItems", batchItems);

        forwardToBatchPage(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        try {
            if ("editItem".equals(action)) {
                int batchItemId = Integer.parseInt(request.getParameter("batchItemId"));
                int batchId = Integer.parseInt(request.getParameter("batchId"));

                BatchItem editItem = batchItemDAO.getItemById(batchItemId);

                if (editItem == null) {
                    request.setAttribute("error", "Không tìm thấy sản phẩm trong lô cần sửa.");
                } else {
                    request.setAttribute("editItem", editItem);
                }

                forwardWithBatchDetail(request, response, batchId);
                return;
            }

            response.sendRedirect(request.getContextPath() + "/BatchServlet");

        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Mã chi tiết lô hàng không hợp lệ.");
            forwardToBatchPage(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải chi tiết lô hàng.");
            forwardToBatchPage(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        try {
            if (action == null || action.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/BatchServlet");
                return;
            }

            switch (action) {
                case "addItem": {
                    int batchId = Integer.parseInt(request.getParameter("batchId"));
                    int productId = Integer.parseInt(request.getParameter("productId"));
                    int importQuantity = Integer.parseInt(request.getParameter("importQuantity"));
                    BigDecimal price = new BigDecimal(request.getParameter("price"));

                    if (importQuantity <= 0) {
                        request.setAttribute("error", "Số lượng nhập phải lớn hơn 0.");
                        forwardWithBatchDetail(request, response, batchId);
                        return;
                    }

                    if (price.compareTo(BigDecimal.ZERO) < 0) {
                        request.setAttribute("error", "Giá nhập không được âm.");
                        forwardWithBatchDetail(request, response, batchId);
                        return;
                    }

                    boolean existed = batchItemDAO.existsBatchProduct(batchId, productId);

                    if (existed) {
                        request.setAttribute("error", "Sản phẩm này đã tồn tại trong lô. Hãy cập nhật thay vì thêm mới.");
                        forwardWithBatchDetail(request, response, batchId);
                        return;
                    }

                    BatchItem item = new BatchItem();
                    item.setBatchId(batchId);
                    item.setProductId(productId);
                    item.setImportQuantity(importQuantity);
                    item.setQuantity(importQuantity);
                    item.setPrice(price);

                    boolean success = batchItemDAO.addItem(item);

                    if (success) {
                        response.sendRedirect(request.getContextPath()
                                + "/BatchServlet?action=viewDetail&batchId=" + batchId);
                    } else {
                        request.setAttribute("error", "Thêm sản phẩm vào lô thất bại.");
                        forwardWithBatchDetail(request, response, batchId);
                    }

                    break;
                }

                case "updateItem": {
                    int batchItemId = Integer.parseInt(request.getParameter("batchItemId"));
                    int batchId = Integer.parseInt(request.getParameter("batchId"));
                    int productId = Integer.parseInt(request.getParameter("productId"));
                    int importQuantity = Integer.parseInt(request.getParameter("importQuantity"));
                    int quantity = Integer.parseInt(request.getParameter("quantity"));
                    BigDecimal price = new BigDecimal(request.getParameter("price"));

                    if (importQuantity <= 0) {
                        request.setAttribute("error", "Số lượng nhập phải lớn hơn 0.");
                        forwardWithBatchDetail(request, response, batchId);
                        return;
                    }

                    if (quantity < 0) {
                        request.setAttribute("error", "Số lượng tồn không được âm.");
                        forwardWithBatchDetail(request, response, batchId);
                        return;
                    }

                    if (price.compareTo(BigDecimal.ZERO) < 0) {
                        request.setAttribute("error", "Giá nhập không được âm.");
                        forwardWithBatchDetail(request, response, batchId);
                        return;
                    }

                    BatchItem item = new BatchItem();
                    item.setBatchItemId(batchItemId);
                    item.setBatchId(batchId);
                    item.setProductId(productId);
                    item.setImportQuantity(importQuantity);
                    item.setQuantity(quantity);
                    item.setPrice(price);

                    boolean success = batchItemDAO.updateItem(item);

                    if (success) {
                        response.sendRedirect(request.getContextPath()
                                + "/BatchServlet?action=viewDetail&batchId=" + batchId);
                    } else {
                        request.setAttribute("error", "Cập nhật sản phẩm trong lô thất bại.");
                        forwardWithBatchDetail(request, response, batchId);
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

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi xử lý chi tiết lô hàng.");
            forwardToBatchPage(request, response);
        }
    }
}
