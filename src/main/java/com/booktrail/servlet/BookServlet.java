package com.booktrail.servlet;

import com.booktrail.dao.BookDAO;
import com.booktrail.dao.BookshelfDAO;
import com.booktrail.dao.DiscussionDAO;
import com.booktrail.dao.ReviewDAO;
import com.booktrail.model.Book;
import com.booktrail.model.BookshelfItem;
import com.booktrail.model.DiscussionRoom;
import com.booktrail.model.Review;
import com.booktrail.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/book")
public class BookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final DiscussionDAO discussionDAO = new DiscussionDAO();
    private final BookshelfDAO shelfDAO = new BookshelfDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/discover");
            return;
        }

        int bookId;
        try {
            bookId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/discover");
            return;
        }

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        int currentUserId = (currentUser != null) ? currentUser.getId() : 0;

        try {
            Book book = bookDAO.findById(bookId, currentUserId);
            if (book == null) {
                resp.sendRedirect(req.getContextPath() + "/discover?error=Book+not+found");
                return;
            }

            List<Review> reviews = reviewDAO.getReviewsForBook(bookId);
            List<DiscussionRoom> rooms = discussionDAO.getRoomsForBook(bookId);
            BookshelfItem shelfItem = null;
            if (currentUser != null) {
                shelfItem = shelfDAO.getItem(currentUser.getId(), bookId);
            }

            req.setAttribute("book", book);
            req.setAttribute("reviews", reviews);
            req.setAttribute("rooms", rooms);
            req.setAttribute("shelfItem", shelfItem);

            req.getRequestDispatcher("/WEB-INF/views/book.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("errorMessage", "Error loading book details: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/discover.jsp").forward(req, resp);
        }
    }
}
