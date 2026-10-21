package com.booktrail.servlet;

import com.booktrail.dao.BookDAO;
import com.booktrail.dao.BookshelfDAO;
import com.booktrail.dao.DiscussionDAO;
import com.booktrail.model.Book;
import com.booktrail.model.BookshelfItem;
import com.booktrail.model.DiscussionRoom;
import com.booktrail.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/community")
public class CommunityServlet extends HttpServlet {

    private final DiscussionDAO discussionDAO = new DiscussionDAO();
    private final BookDAO bookDAO = new BookDAO();
    private final BookshelfDAO shelfDAO = new BookshelfDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String bookIdStr = req.getParameter("bookId");
        Integer bookFilterId = null;
        if (bookIdStr != null && !bookIdStr.trim().isEmpty()) {
            try {
                bookFilterId = Integer.parseInt(bookIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        try {
            List<DiscussionRoom> rooms;
            if (bookFilterId != null) {
                rooms = discussionDAO.getRoomsForBook(bookFilterId);
            } else {
                rooms = discussionDAO.getAllRooms();
            }

            List<Book> allBooks = bookDAO.getAllBooks(currentUser != null ? currentUser.getId() : 0);

            // Compute user progress per book to indicate spoiler-safe vs spoiler-locked status in UI
            Map<Integer, Integer> userProgressMap = new HashMap<>();
            if (currentUser != null) {
                List<BookshelfItem> shelf = shelfDAO.getBookshelf(currentUser.getId(), "ALL");
                for (BookshelfItem item : shelf) {
                    userProgressMap.put(item.getBookId(), item.getChaptersRead());
                }
            }

            req.setAttribute("rooms", rooms);
            req.setAttribute("books", allBooks);
            req.setAttribute("selectedBookId", bookFilterId);
            req.setAttribute("userProgressMap", userProgressMap);

            req.getRequestDispatcher("/WEB-INF/views/community.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("errorMessage", "Error loading community discussions: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/community.jsp").forward(req, resp);
        }
    }
}
