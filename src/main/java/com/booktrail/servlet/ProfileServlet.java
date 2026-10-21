package com.booktrail.servlet;

import com.booktrail.dao.BookDAO;
import com.booktrail.dao.BookshelfDAO;
import com.booktrail.dao.ReviewDAO;
import com.booktrail.dao.UserDAO;
import com.booktrail.model.Book;
import com.booktrail.model.BookshelfItem;
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

@WebServlet(urlPatterns = {"/profile", "/review/save", "/review/delete", "/profile/bio"})
public class ProfileServlet extends HttpServlet {

    private final BookshelfDAO shelfDAO = new BookshelfDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final UserDAO userDAO = new UserDAO();
    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            // Fresh user data
            User freshUser = userDAO.findById(currentUser.getId());
            if (freshUser != null) {
                session.setAttribute("currentUser", freshUser);
                currentUser = freshUser;
            }

            int[] stats = shelfDAO.getUserStats(currentUser.getId());
            List<Review> userReviews = reviewDAO.getReviewsByUser(currentUser.getId());
            List<BookshelfItem> completedBooks = shelfDAO.getBookshelf(currentUser.getId(), "COMPLETED");
            List<Book> allBooks = bookDAO.getAllBooks(currentUser.getId());

            req.setAttribute("stats", stats);
            req.setAttribute("userReviews", userReviews);
            req.setAttribute("completedBooks", completedBooks);
            req.setAttribute("allBooks", allBooks);

            req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("errorMessage", "Error loading profile: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String servletPath = req.getServletPath();
        String redirect = req.getParameter("redirect");

        try {
            if ("/review/save".equals(servletPath)) {
                int bookId = Integer.parseInt(req.getParameter("bookId"));
                int rating = Integer.parseInt(req.getParameter("rating"));
                String reviewText = req.getParameter("reviewText");

                if (reviewText != null && !reviewText.trim().isEmpty() && rating >= 1 && rating <= 5) {
                    Review review = new Review();
                    review.setBookId(bookId);
                    review.setUserId(currentUser.getId());
                    review.setRating(rating);
                    review.setReviewText(reviewText.trim());
                    reviewDAO.upsertReview(review);
                }
                if (redirect != null && !redirect.trim().isEmpty() && redirect.startsWith(req.getContextPath())) {
                    resp.sendRedirect(redirect + (redirect.contains("?") ? "&" : "?") + "success=Review+published+successfully!");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/profile?success=Review+saved+successfully!");
                }
            } else if ("/review/delete".equals(servletPath)) {
                String reviewIdStr = req.getParameter("reviewId");
                if (reviewIdStr != null && !reviewIdStr.trim().isEmpty()) {
                    int reviewId = Integer.parseInt(reviewIdStr.trim());
                    Review existing = reviewDAO.getReviewById(reviewId);
                    if (existing != null && (currentUser.isAdmin() || existing.getUserId() == currentUser.getId())) {
                        reviewDAO.deleteReview(reviewId);
                    }
                }
                if (redirect != null && !redirect.trim().isEmpty() && redirect.startsWith(req.getContextPath())) {
                    resp.sendRedirect(redirect + (redirect.contains("?") ? "&" : "?") + "success=Review+deleted!");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/profile?success=Review+deleted!");
                }
            } else if ("/profile/bio".equals(servletPath)) {
                String bio = req.getParameter("bio");
                if (bio != null) {
                    userDAO.updateBio(currentUser.getId(), bio.trim());
                    currentUser.setBio(bio.trim());
                    session.setAttribute("currentUser", currentUser);
                }
                resp.sendRedirect(req.getContextPath() + "/profile?success=Bio+updated!");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/profile?error=" + e.getMessage());
        }
    }
}
