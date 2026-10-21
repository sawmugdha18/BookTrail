package com.booktrail.servlet;

import com.booktrail.dao.BookDAO;
import com.booktrail.model.Book;
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

@WebServlet(urlPatterns = {"", "/discover", "/books"})
public class DiscoverServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final com.booktrail.dao.DiscussionDAO discussionDAO = new com.booktrail.dao.DiscussionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if (path != null && path.startsWith("/static/")) {
            req.getServletContext().getNamedDispatcher("default").forward(req, resp);
            return;
        }

        String query = req.getParameter("q");
        String genre = req.getParameter("genre");
        String sort = req.getParameter("sort");

        HttpSession session = req.getSession(false);
        int currentUserId = 0;
        if (session != null) {
            User user = (User) session.getAttribute("currentUser");
            if (user != null) {
                currentUserId = user.getId();
            }
        }

        try {
            List<Book> books = bookDAO.searchBooks(query, genre, currentUserId);
            List<String> genres = bookDAO.getGenres();
            List<com.booktrail.model.DiscussionRoom> featuredRooms = discussionDAO.getAllRooms();

            // Client/Servlet sort options: rating, chapters, title
            if ("rating".equalsIgnoreCase(sort)) {
                books.sort((a, b) -> Double.compare(b.getAverageRating(), a.getAverageRating()));
            } else if ("chapters".equalsIgnoreCase(sort)) {
                books.sort((a, b) -> Integer.compare(b.getTotalChapters(), a.getTotalChapters()));
            } else if ("title".equalsIgnoreCase(sort)) {
                books.sort((a, b) -> a.getTitle().compareToIgnoreCase(b.getTitle()));
            }

            req.setAttribute("books", books);
            req.setAttribute("genres", genres);
            req.setAttribute("featuredRooms", featuredRooms);
            req.setAttribute("currentQuery", query != null ? query.trim() : "");
            req.setAttribute("currentGenre", genre != null ? genre.trim() : "ALL");
            req.setAttribute("currentSort", sort != null ? sort.trim() : "");

            req.getRequestDispatcher("/WEB-INF/views/discover.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("errorMessage", "Error loading books: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/discover.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
