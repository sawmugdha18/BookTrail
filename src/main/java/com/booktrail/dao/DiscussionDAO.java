package com.booktrail.dao;

import com.booktrail.config.DBConnection;
import com.booktrail.model.Book;
import com.booktrail.model.Comment;
import com.booktrail.model.DiscussionRoom;
import com.booktrail.model.Post;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class DiscussionDAO {

    public List<DiscussionRoom> getAllRooms() throws SQLException {
        List<DiscussionRoom> list = new ArrayList<>();
        String sql = "SELECT r.id, r.book_id, r.title, r.chapter_start, r.chapter_end, r.description, r.created_at, " +
                     "b.title AS book_title, b.author AS book_author, b.genre AS book_genre, b.total_chapters, b.cover_url, " +
                     "COUNT(p.id) AS post_count " +
                     "FROM discussion_rooms r " +
                     "JOIN books b ON r.book_id = b.id " +
                     "LEFT JOIN posts p ON r.id = p.room_id " +
                     "GROUP BY r.id, r.book_id, r.title, r.chapter_start, r.chapter_end, r.description, r.created_at, " +
                     "b.title, b.author, b.genre, b.total_chapters, b.cover_url " +
                     "ORDER BY b.title ASC, r.chapter_start ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                DiscussionRoom room = new DiscussionRoom(
                        rs.getInt("id"),
                        rs.getInt("book_id"),
                        rs.getString("title"),
                        rs.getInt("chapter_start"),
                        rs.getInt("chapter_end"),
                        rs.getString("description"),
                        rs.getTimestamp("created_at")
                );
                room.setPostCount(rs.getInt("post_count"));
                Book b = new Book();
                b.setId(rs.getInt("book_id"));
                b.setTitle(rs.getString("book_title"));
                b.setAuthor(rs.getString("book_author"));
                b.setGenre(rs.getString("book_genre"));
                b.setTotalChapters(rs.getInt("total_chapters"));
                b.setCoverUrl(rs.getString("cover_url"));
                room.setBook(b);
                list.add(room);
            }
        }
        return list;
    }

    public List<DiscussionRoom> getRoomsForBook(int bookId) throws SQLException {
        List<DiscussionRoom> list = new ArrayList<>();
        String sql = "SELECT r.id, r.book_id, r.title, r.chapter_start, r.chapter_end, r.description, r.created_at, " +
                     "b.title AS book_title, b.author AS book_author, b.genre AS book_genre, b.total_chapters, b.cover_url, " +
                     "COUNT(p.id) AS post_count " +
                     "FROM discussion_rooms r " +
                     "JOIN books b ON r.book_id = b.id " +
                     "LEFT JOIN posts p ON r.id = p.room_id " +
                     "WHERE r.book_id = ? " +
                     "GROUP BY r.id, r.book_id, r.title, r.chapter_start, r.chapter_end, r.description, r.created_at, " +
                     "b.title, b.author, b.genre, b.total_chapters, b.cover_url " +
                     "ORDER BY r.chapter_start ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DiscussionRoom room = new DiscussionRoom(
                            rs.getInt("id"),
                            rs.getInt("book_id"),
                            rs.getString("title"),
                            rs.getInt("chapter_start"),
                            rs.getInt("chapter_end"),
                            rs.getString("description"),
                            rs.getTimestamp("created_at")
                    );
                    room.setPostCount(rs.getInt("post_count"));
                    Book b = new Book();
                    b.setId(rs.getInt("book_id"));
                    b.setTitle(rs.getString("book_title"));
                    b.setAuthor(rs.getString("book_author"));
                    b.setGenre(rs.getString("book_genre"));
                    b.setTotalChapters(rs.getInt("total_chapters"));
                    b.setCoverUrl(rs.getString("cover_url"));
                    room.setBook(b);
                    list.add(room);
                }
            }
        }
        return list;
    }

    public DiscussionRoom getRoomById(int roomId) throws SQLException {
        String sql = "SELECT r.id, r.book_id, r.title, r.chapter_start, r.chapter_end, r.description, r.created_at, " +
                     "b.title AS book_title, b.author AS book_author, b.genre AS book_genre, b.total_chapters, b.cover_url, " +
                     "COUNT(p.id) AS post_count " +
                     "FROM discussion_rooms r " +
                     "JOIN books b ON r.book_id = b.id " +
                     "LEFT JOIN posts p ON r.id = p.room_id " +
                     "WHERE r.id = ? " +
                     "GROUP BY r.id, r.book_id, r.title, r.chapter_start, r.chapter_end, r.description, r.created_at, " +
                     "b.title, b.author, b.genre, b.total_chapters, b.cover_url";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    DiscussionRoom room = new DiscussionRoom(
                            rs.getInt("id"),
                            rs.getInt("book_id"),
                            rs.getString("title"),
                            rs.getInt("chapter_start"),
                            rs.getInt("chapter_end"),
                            rs.getString("description"),
                            rs.getTimestamp("created_at")
                    );
                    room.setPostCount(rs.getInt("post_count"));
                    Book b = new Book();
                    b.setId(rs.getInt("book_id"));
                    b.setTitle(rs.getString("book_title"));
                    b.setAuthor(rs.getString("book_author"));
                    b.setGenre(rs.getString("book_genre"));
                    b.setTotalChapters(rs.getInt("total_chapters"));
                    b.setCoverUrl(rs.getString("cover_url"));
                    room.setBook(b);
                    return room;
                }
            }
        }
        return null;
    }

    public List<Post> getPostsForRoom(int roomId) throws SQLException {
        List<Post> list = new ArrayList<>();
        String sql = "SELECT p.id, p.room_id, p.user_id, p.title, p.content, p.has_spoilers, p.created_at, " +
                     "u.username AS author_name, u.bio AS author_bio, " +
                     "COUNT(c.id) AS comment_count " +
                     "FROM posts p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "LEFT JOIN comments c ON p.id = c.post_id " +
                     "WHERE p.room_id = ? " +
                     "GROUP BY p.id, p.room_id, p.user_id, p.title, p.content, p.has_spoilers, p.created_at, u.username, u.bio " +
                     "ORDER BY p.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Post p = new Post(
                            rs.getInt("id"),
                            rs.getInt("room_id"),
                            rs.getInt("user_id"),
                            rs.getString("title"),
                            rs.getString("content"),
                            rs.getBoolean("has_spoilers"),
                            rs.getTimestamp("created_at")
                    );
                    p.setAuthorUsername(rs.getString("author_name"));
                    p.setAuthorBio(rs.getString("author_bio"));
                    p.setCommentCount(rs.getInt("comment_count"));
                    list.add(p);
                }
            }
        }

        // Attach comments to each post
        for (Post post : list) {
            post.setComments(getCommentsForPost(post.getId()));
        }

        return list;
    }

    public boolean createPost(Post post) throws SQLException {
        String sql = "INSERT INTO posts (room_id, user_id, title, content, has_spoilers) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, post.getRoomId());
            ps.setInt(2, post.getUserId());
            ps.setString(3, post.getTitle());
            ps.setString(4, post.getContent());
            ps.setBoolean(5, post.isHasSpoilers());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        post.setId(keys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }

    public Post getPostById(int postId) throws SQLException {
        String sql = "SELECT p.id, p.room_id, p.user_id, p.title, p.content, p.has_spoilers, p.created_at, " +
                     "u.username AS author_name, u.bio AS author_bio " +
                     "FROM posts p JOIN users u ON p.user_id = u.id WHERE p.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Post p = new Post(
                            rs.getInt("id"),
                            rs.getInt("room_id"),
                            rs.getInt("user_id"),
                            rs.getString("title"),
                            rs.getString("content"),
                            rs.getBoolean("has_spoilers"),
                            rs.getTimestamp("created_at")
                    );
                    p.setAuthorUsername(rs.getString("author_name"));
                    p.setAuthorBio(rs.getString("author_bio"));
                    return p;
                }
            }
        }
        return null;
    }

    public boolean deletePost(int postId) throws SQLException {
        String sql = "DELETE FROM posts WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            return ps.executeUpdate() > 0;
        }
    }

    public Comment getCommentById(int commentId) throws SQLException {
        String sql = "SELECT c.id, c.post_id, c.user_id, c.content, c.created_at, u.username AS author_name " +
                     "FROM comments c JOIN users u ON c.user_id = u.id WHERE c.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Comment c = new Comment(
                            rs.getInt("id"),
                            rs.getInt("post_id"),
                            rs.getInt("user_id"),
                            rs.getString("content"),
                            rs.getTimestamp("created_at")
                    );
                    c.setAuthorUsername(rs.getString("author_name"));
                    return c;
                }
            }
        }
        return null;
    }

    public boolean deleteComment(int commentId) throws SQLException {
        String sql = "DELETE FROM comments WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            return ps.executeUpdate() > 0;
        }
    }

    public List<Comment> getCommentsForPost(int postId) throws SQLException {
        List<Comment> list = new ArrayList<>();
        String sql = "SELECT c.id, c.post_id, c.user_id, c.content, c.created_at, u.username AS author_name " +
                     "FROM comments c " +
                     "JOIN users u ON c.user_id = u.id " +
                     "WHERE c.post_id = ? " +
                     "ORDER BY c.created_at ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Comment c = new Comment(
                            rs.getInt("id"),
                            rs.getInt("post_id"),
                            rs.getInt("user_id"),
                            rs.getString("content"),
                            rs.getTimestamp("created_at")
                    );
                    c.setAuthorUsername(rs.getString("author_name"));
                    list.add(c);
                }
            }
        }
        return list;
    }

    public boolean createComment(Comment comment) throws SQLException {
        String sql = "INSERT INTO comments (post_id, user_id, content) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, comment.getPostId());
            ps.setInt(2, comment.getUserId());
            ps.setString(3, comment.getContent());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        comment.setId(keys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }

    public boolean createRoom(DiscussionRoom room) throws SQLException {
        String sql = "INSERT INTO discussion_rooms (book_id, title, chapter_start, chapter_end, description) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, room.getBookId());
            ps.setString(2, room.getTitle());
            ps.setInt(3, room.getChapterStart());
            ps.setInt(4, room.getChapterEnd());
            ps.setString(5, room.getDescription());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        room.setId(keys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }
}
