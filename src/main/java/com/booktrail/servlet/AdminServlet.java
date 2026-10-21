package com.booktrail.servlet;

import com.booktrail.config.DBConnection;
import com.booktrail.dao.BookDAO;
import com.booktrail.dao.DiscussionDAO;
import com.booktrail.dao.UserDAO;
import com.booktrail.model.Book;
import com.booktrail.model.DiscussionRoom;
import com.booktrail.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = {"/admin", "/admin/book/add", "/admin/book/delete", "/admin/room/add"})
public class AdminServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final BookDAO bookDAO = new BookDAO();
    private final DiscussionDAO discussionDAO = new DiscussionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<User> users = userDAO.getAllUsers();
            List<Book> books = bookDAO.getAllBooks(0);
            List<DiscussionRoom> rooms = discussionDAO.getAllRooms();

            req.setAttribute("users", users);
            req.setAttribute("books", books);
            req.setAttribute("rooms", rooms);
            req.setAttribute("isMySql", DBConnection.isUsingMySql());

            req.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("errorMessage", "Error loading admin console: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        try {
            if ("/admin/book/add".equals(servletPath)) {
                String title = req.getParameter("title");
                String author = req.getParameter("author");
                String genre = req.getParameter("genre");
                int chapters = Integer.parseInt(req.getParameter("totalChapters"));
                String synopsis = req.getParameter("synopsis");
                String coverUrl = req.getParameter("coverUrl");
                int year = Integer.parseInt(req.getParameter("publishedYear"));

                Book b = new Book();
                b.setTitle(title.trim());
                b.setAuthor(author.trim());
                b.setGenre(genre.trim());
                b.setTotalChapters(chapters);
                b.setSynopsis(synopsis.trim());
                b.setCoverUrl(coverUrl != null && !coverUrl.trim().isEmpty() ? coverUrl.trim() : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&auto=format&fit=crop&q=80");
                b.setPublishedYear(year);

                bookDAO.create(b);
                resp.sendRedirect(req.getContextPath() + "/admin?success=Book+added+successfully!");
            } else if ("/admin/book/delete".equals(servletPath)) {
                int bookId = Integer.parseInt(req.getParameter("bookId"));
                bookDAO.delete(bookId);
                resp.sendRedirect(req.getContextPath() + "/admin?success=Book+deleted!");
            } else if ("/admin/room/add".equals(servletPath)) {
                int bookId = Integer.parseInt(req.getParameter("bookId"));
                String title = req.getParameter("title");
                int chStart = Integer.parseInt(req.getParameter("chapterStart"));
                int chEnd = Integer.parseInt(req.getParameter("chapterEnd"));
                String desc = req.getParameter("description");

                DiscussionRoom room = new DiscussionRoom();
                room.setBookId(bookId);
                room.setTitle(title.trim());
                room.setChapterStart(chStart);
                room.setChapterEnd(chEnd);
                room.setDescription(desc != null ? desc.trim() : "");

                discussionDAO.createRoom(room);
                resp.sendRedirect(req.getContextPath() + "/admin?success=Discussion+room+created!");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin?error=" + e.getMessage());
        }
    }
}
