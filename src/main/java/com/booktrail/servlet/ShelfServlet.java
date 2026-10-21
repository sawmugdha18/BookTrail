package com.booktrail.servlet;

import com.booktrail.dao.BookshelfDAO;
import com.booktrail.model.BookshelfItem;
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

@WebServlet(urlPatterns = {"/shelf", "/shelf/add", "/shelf/update", "/shelf/remove"})
public class ShelfServlet extends HttpServlet {

    private final BookshelfDAO shelfDAO = new BookshelfDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login?error=Please+login+to+view+your+shelf");
            return;
        }

        String filter = req.getParameter("status");
        if (filter == null || filter.trim().isEmpty()) {
            filter = "ALL";
        }

        try {
            List<BookshelfItem> items = shelfDAO.getBookshelf(user.getId(), filter);
            int[] stats = shelfDAO.getUserStats(user.getId());

            req.setAttribute("shelfItems", items);
            req.setAttribute("currentStatus", filter.toUpperCase());
            req.setAttribute("completedCount", stats[0]);
            req.setAttribute("totalChaptersRead", stats[1]);
            req.setAttribute("readingCount", stats[2]);
            req.setAttribute("wantCount", stats[3]);

            req.getRequestDispatcher("/WEB-INF/views/shelf.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("errorMessage", "Error loading your shelf: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/shelf.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String servletPath = req.getServletPath();
        String bookIdStr = req.getParameter("bookId");
        String redirect = req.getParameter("redirect");

        if (bookIdStr == null || bookIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/shelf");
            return;
        }

        int bookId;
        try {
            bookId = Integer.parseInt(bookIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/shelf");
            return;
        }

        try {
            if ("/shelf/remove".equals(servletPath)) {
                shelfDAO.removeFromShelf(user.getId(), bookId);
            } else if ("/shelf/update".equals(servletPath)) {
                String chaptersReadStr = req.getParameter("chaptersRead");
                String status = req.getParameter("status");
                String notes = req.getParameter("notes");

                BookshelfItem current = shelfDAO.getItem(user.getId(), bookId);
                int targetChapters = (current != null) ? current.getChaptersRead() : 0;
                if (chaptersReadStr != null && !chaptersReadStr.trim().isEmpty()) {
                    try {
                        targetChapters = Math.max(0, Integer.parseInt(chaptersReadStr.trim()));
                    } catch (NumberFormatException ignored) {}
                }

                String targetStatus = (status != null && !status.trim().isEmpty()) ? status.trim().toUpperCase() : (current != null ? current.getStatus() : "CURRENTLY_READING");
                String targetNotes = (notes != null) ? notes.trim() : (current != null ? current.getNotes() : "");

                if (current != null && current.getBook() != null) {
                    int total = current.getBook().getTotalChapters();
                    if (targetChapters >= total) {
                        targetStatus = "COMPLETED";
                        targetChapters = total;
                    } else if ("WANT_TO_READ".equals(targetStatus) && targetChapters > 0) {
                        targetStatus = "CURRENTLY_READING";
                    }
                }

                shelfDAO.upsertShelfItem(user.getId(), bookId, targetStatus, targetChapters, targetNotes);
            } else if ("/shelf/add".equals(servletPath)) {
                String status = req.getParameter("status");
                if (status == null || status.trim().isEmpty()) {
                    status = "WANT_TO_READ";
                }
                BookshelfItem current = shelfDAO.getItem(user.getId(), bookId);
                if (current == null) {
                    shelfDAO.upsertShelfItem(user.getId(), bookId, status.trim().toUpperCase(), 0, "");
                }
            }
        } catch (SQLException e) {
            // Log and redirect
        }

        if (redirect != null && !redirect.trim().isEmpty() && redirect.startsWith(req.getContextPath())) {
            resp.sendRedirect(redirect);
        } else {
            resp.sendRedirect(req.getContextPath() + "/shelf");
        }
    }
}
