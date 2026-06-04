/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;


import dal.BatchDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "BatchServlet", urlPatterns = {"/batch"})
public class BatchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        BatchDAO dao = new BatchDAO();

        request.setAttribute("batchList", dao.getAllBatches());
        request.getRequestDispatcher("/views/batch.jsp").forward(request, response);
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        BatchDAO dao = new BatchDAO();

        try {
            if ("add".equals(action)) {
                String batchName = request.getParameter("batchName");
                int categoryId = Integer.parseInt(request.getParameter("categoryId"));
                int brandId = Integer.parseInt(request.getParameter("brandId"));

                dao.addBatch(batchName, categoryId, brandId);
            }

            if ("update".equals(action)) {
    int batchId = Integer.parseInt(request.getParameter("batchId"));
    String batchName = request.getParameter("batchName");
    int categoryId = Integer.parseInt(request.getParameter("categoryId"));
    int brandId = Integer.parseInt(request.getParameter("brandId"));

    dao.updateBatch(batchId, batchName, categoryId, brandId);
}

            if ("delete".equals(action)) {
                int batchId = Integer.parseInt(request.getParameter("batchId"));
                dao.deleteBatch(batchId);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/batch");
    }
}