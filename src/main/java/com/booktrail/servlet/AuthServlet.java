package com.booktrail.servlet;

import com.booktrail.dao.UserDAO;
import com.booktrail.model.User;
import com.booktrail.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(urlPatterns = {"/login", "/register", "/logout"})
public class AuthServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/logout".equals(servletPath)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            resp.sendRedirect(req.getContextPath() + "/login?msg=You+have+been+logged+out+safely.");
            return;
        }

        if ("/login".equals(servletPath)) {
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        if ("/register".equals(servletPath)) {
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();

        if ("/login".equals(servletPath)) {
            handleLogin(req, resp);
        } else if ("/register".equals(servletPath)) {
            handleRegister(req, resp);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String redirect = req.getParameter("redirect");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Please provide both username and password.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        try {
            User user = userDAO.findByUsername(username.trim());
            if (user != null && PasswordUtil.verifyPassword(password, user.getSalt(), user.getPasswordHash())) {
                HttpSession session = req.getSession(true);
                session.setAttribute("currentUser", user);

                if (redirect != null && !redirect.trim().isEmpty() && redirect.startsWith(req.getContextPath())) {
                    resp.sendRedirect(redirect);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/discover");
                }
                return;
            } else {
                req.setAttribute("errorMessage", "Invalid username or password. Please try again.");
                req.setAttribute("username", username);
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                return;
            }
        } catch (SQLException e) {
            req.setAttribute("errorMessage", "Database error occurred: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String bio = req.getParameter("bio");

        // Server-side validations
        if (username == null || username.trim().length() < 3) {
            req.setAttribute("errorMessage", "Username must be at least 3 characters long.");
            preserveForm(req, username, email, bio);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        if (email == null || !email.contains("@") || !email.contains(".")) {
            req.setAttribute("errorMessage", "Please provide a valid email address.");
            preserveForm(req, username, email, bio);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        if (password == null || password.length() < 6) {
            req.setAttribute("errorMessage", "Password must be at least 6 characters.");
            preserveForm(req, username, email, bio);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("errorMessage", "Passwords do not match.");
            preserveForm(req, username, email, bio);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        try {
            if (userDAO.findByUsername(username.trim()) != null) {
                req.setAttribute("errorMessage", "Username is already taken.");
                preserveForm(req, username, email, bio);
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
                return;
            }

            if (userDAO.findByEmail(email.trim()) != null) {
                req.setAttribute("errorMessage", "Email is already registered.");
                preserveForm(req, username, email, bio);
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
                return;
            }

            String salt = PasswordUtil.generateSalt();
            String hash = PasswordUtil.hashPassword(password, salt);

            User newUser = new User();
            newUser.setUsername(username.trim());
            newUser.setEmail(email.trim());
            newUser.setPasswordHash(hash);
            newUser.setSalt(salt);
            newUser.setRole("USER");
            newUser.setBio(bio != null ? bio.trim() : "");

            boolean created = userDAO.create(newUser);
            if (created) {
                HttpSession session = req.getSession(true);
                session.setAttribute("currentUser", newUser);
                resp.sendRedirect(req.getContextPath() + "/discover?success=Welcome+to+BookTrail!");
            } else {
                req.setAttribute("errorMessage", "Could not complete registration. Please try again.");
                preserveForm(req, username, email, bio);
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("errorMessage", "Database error: " + e.getMessage());
            preserveForm(req, username, email, bio);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
        }
    }

    private void preserveForm(HttpServletRequest req, String username, String email, String bio) {
        req.setAttribute("username", username);
        req.setAttribute("email", email);
        req.setAttribute("bio", bio);
    }
}
