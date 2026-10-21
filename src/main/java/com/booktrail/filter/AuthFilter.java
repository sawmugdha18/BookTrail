package com.booktrail.filter;

import com.booktrail.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        // Force UTF-8 character encoding across all endpoints
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Protected user routes
        boolean isUserProtected = path.startsWith("/shelf") ||
                                  path.startsWith("/profile") ||
                                  path.startsWith("/post/") ||
                                  path.startsWith("/comment/") ||
                                  path.startsWith("/review/");

        // Protected admin routes
        boolean isAdminProtected = path.startsWith("/admin");

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (isUserProtected && currentUser == null) {
            String target = req.getRequestURI();
            if (req.getQueryString() != null) {
                target += "?" + req.getQueryString();
            }
            resp.sendRedirect(req.getContextPath() + "/login?error=Please+login+to+continue&redirect=" + java.net.URLEncoder.encode(target, "UTF-8"));
            return;
        }

        if (isAdminProtected) {
            if (currentUser == null) {
                resp.sendRedirect(req.getContextPath() + "/login?error=Admin+login+required");
                return;
            } else if (!currentUser.isAdmin()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Administrator privileges required.");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
