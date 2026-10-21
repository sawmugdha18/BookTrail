package com.booktrail.servlet;

import com.booktrail.dao.BookshelfDAO;
import com.booktrail.dao.DiscussionDAO;
import com.booktrail.model.BookshelfItem;
import com.booktrail.model.Comment;
import com.booktrail.model.DiscussionRoom;
import com.booktrail.model.Post;
import com.booktrail.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

@WebServlet(urlPatterns = {"/room", "/post/create", "/comment/create", "/post/delete", "/comment/delete"})
public class RoomServlet extends HttpServlet {

    private final DiscussionDAO discussionDAO = new DiscussionDAO();
    private final BookshelfDAO shelfDAO = new BookshelfDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String roomIdStr = req.getParameter("id");
        if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/community");
            return;
        }

        int roomId;
        try {
            roomId = Integer.parseInt(roomIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/community");
            return;
        }

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        try {
            DiscussionRoom room = discussionDAO.getRoomById(roomId);
            if (room == null) {
                resp.sendRedirect(req.getContextPath() + "/community?error=Discussion+room+not+found");
                return;
            }

            // SERVER-SIDE SPOILER ACCESS CHECK
            int userChapters = 0;
            boolean hasBookInShelf = false;
            if (currentUser != null) {
                BookshelfItem item = shelfDAO.getItem(currentUser.getId(), room.getBookId());
                if (item != null) {
                    userChapters = item.getChaptersRead();
                    hasBookInShelf = true;
                }
            }

            boolean isBypassed = "true".equalsIgnoreCase(req.getParameter("bypass")) ||
                    (session != null && Boolean.TRUE.equals(session.getAttribute("spoiler_bypass_" + roomId)));

            if (isBypassed && session != null) {
                session.setAttribute("spoiler_bypass_" + roomId, true);
            }

            boolean isSpoilerBlocked = false;
            // Block if user is logged in, has not completed up to chapter_end, and has not explicitly bypassed
            if (currentUser != null && !currentUser.isAdmin()) {
                if (userChapters < room.getChapterEnd() && !isBypassed) {
                    isSpoilerBlocked = true;
                }
            } else if (currentUser == null && !isBypassed) {
                // If guest has not accepted spoiler warning, gate the room
                isSpoilerBlocked = true;
            }

            req.setAttribute("room", room);
            req.setAttribute("userChapters", userChapters);
            req.setAttribute("hasBookInShelf", hasBookInShelf);
            req.setAttribute("isSpoilerBlocked", isSpoilerBlocked);

            if (!isSpoilerBlocked) {
                List<Post> posts = discussionDAO.getPostsForRoom(roomId);
                req.setAttribute("posts", posts);
            } else {
                // SENSITIVE POSTS KEPT HIDDEN ON SERVER-SIDE
                req.setAttribute("posts", Collections.emptyList());
            }

            req.getRequestDispatcher("/WEB-INF/views/room.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("errorMessage", "Error loading discussion room: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/community.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login?error=Please+login+to+participate+in+discussions");
            return;
        }

        try {
            if ("/post/create".equals(servletPath)) {
                int roomId = Integer.parseInt(req.getParameter("roomId"));
                String title = req.getParameter("title");
                String content = req.getParameter("content");
                boolean hasSpoilers = "on".equalsIgnoreCase(req.getParameter("hasSpoilers")) || "true".equalsIgnoreCase(req.getParameter("hasSpoilers"));

                if (title != null && !title.trim().isEmpty() && content != null && !content.trim().isEmpty()) {
                    Post post = new Post();
                    post.setRoomId(roomId);
                    post.setUserId(currentUser.getId());
                    post.setTitle(title.trim());
                    post.setContent(content.trim());
                    post.setHasSpoilers(hasSpoilers);
                    discussionDAO.createPost(post);
                }
                resp.sendRedirect(req.getContextPath() + "/room?id=" + roomId + "&bypass=true");
            } else if ("/comment/create".equals(servletPath)) {
                int roomId = Integer.parseInt(req.getParameter("roomId"));
                int postId = Integer.parseInt(req.getParameter("postId"));
                String content = req.getParameter("content");

                if (content != null && !content.trim().isEmpty()) {
                    Comment comment = new Comment();
                    comment.setPostId(postId);
                    comment.setUserId(currentUser.getId());
                    comment.setContent(content.trim());
                    discussionDAO.createComment(comment);
                }
                resp.sendRedirect(req.getContextPath() + "/room?id=" + roomId + "&bypass=true#post-" + postId);
            } else if ("/post/delete".equals(servletPath)) {
                int roomId = Integer.parseInt(req.getParameter("roomId"));
                int postId = Integer.parseInt(req.getParameter("postId"));
                Post post = discussionDAO.getPostById(postId);
                if (post != null && (currentUser.isAdmin() || post.getUserId() == currentUser.getId())) {
                    discussionDAO.deletePost(postId);
                }
                resp.sendRedirect(req.getContextPath() + "/room?id=" + roomId + "&bypass=true");
            } else if ("/comment/delete".equals(servletPath)) {
                int roomId = Integer.parseInt(req.getParameter("roomId"));
                int commentId = Integer.parseInt(req.getParameter("commentId"));
                Comment comment = discussionDAO.getCommentById(commentId);
                if (comment != null && (currentUser.isAdmin() || comment.getUserId() == currentUser.getId())) {
                    discussionDAO.deleteComment(commentId);
                }
                resp.sendRedirect(req.getContextPath() + "/room?id=" + roomId + "&bypass=true");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/community?error=" + e.getMessage());
        }
    }
}
