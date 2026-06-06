package controller;

import dal.CategoryDAO;
import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import model.Category;
import model.Product;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home", "/Home"})
public class HomeServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        List<Category> categories = categoryDAO.getAllCategories();
        List<Product> products = productDAO.getAllProducts("newest");

        System.out.println("HOME PRODUCTS SIZE = " + products.size());

        request.setAttribute("categories", categories);
        request.setAttribute("products", products);
        request.setAttribute("productDAO", productDAO);

        request.getRequestDispatcher("/views/home.jsp").forward(request, response);
    }
}
