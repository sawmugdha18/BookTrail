package com.booktrail.dao;

import com.booktrail.config.DBConnection;
import com.booktrail.model.Review;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    public List<Review> getReviewsForBook(int bookId) throws SQLException {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.id, r.book_id, r.user_id, r.rating, r.review_text, r.created_at, " +
                     "u.username AS author_name " +
                     "FROM reviews r " +
                     "JOIN users u ON r.user_id = u.id " +
                     "WHERE r.book_id = ? " +
                     "ORDER BY r.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review(
                            rs.getInt("id"),
                            rs.getInt("book_id"),
                            rs.getInt("user_id"),
                            rs.getInt("rating"),
                            rs.getString("review_text"),
                            rs.getTimestamp("created_at")
                    );
                    r.setAuthorUsername(rs.getString("author_name"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    public List<Review> getReviewsByUser(int userId) throws SQLException {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.id, r.book_id, r.user_id, r.rating, r.review_text, r.created_at, " +
                     "b.title AS book_title, b.author AS book_author " +
                     "FROM reviews r " +
                     "JOIN books b ON r.book_id = b.id " +
                     "WHERE r.user_id = ? " +
                     "ORDER BY r.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review(
                            rs.getInt("id"),
                            rs.getInt("book_id"),
                            rs.getInt("user_id"),
                            rs.getInt("rating"),
                            rs.getString("review_text"),
                            rs.getTimestamp("created_at")
                    );
                    r.setBookTitle(rs.getString("book_title"));
                    r.setBookAuthor(rs.getString("book_author"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    public boolean upsertReview(Review review) throws SQLException {
        String checkSql = "SELECT id FROM reviews WHERE user_id = ? AND book_id = ?";
        Integer existingId = null;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, review.getUserId());
            ps.setInt(2, review.getBookId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    existingId = rs.getInt("id");
                }
            }
        }

        if (existingId == null) {
            String insertSql = "INSERT INTO reviews (book_id, user_id, rating, review_text) VALUES (?, ?, ?, ?)";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, review.getBookId());
                ps.setInt(2, review.getUserId());
                ps.setInt(3, review.getRating());
                ps.setString(4, review.getReviewText());
                return ps.executeUpdate() > 0;
            }
        } else {
            String updateSql = "UPDATE reviews SET rating = ?, review_text = ?, created_at = CURRENT_TIMESTAMP WHERE id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, review.getRating());
                ps.setString(2, review.getReviewText());
                ps.setInt(3, existingId);
                return ps.executeUpdate() > 0;
            }
        }
    }

    public Review getReviewById(int id) throws SQLException {
        String sql = "SELECT id, book_id, user_id, rating, review_text, created_at FROM reviews WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Review(
                            rs.getInt("id"),
                            rs.getInt("book_id"),
                            rs.getInt("user_id"),
                            rs.getInt("rating"),
                            rs.getString("review_text"),
                            rs.getTimestamp("created_at")
                    );
                }
            }
        }
        return null;
    }

    public boolean deleteReview(int reviewId) throws SQLException {
        String sql = "DELETE FROM reviews WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            return ps.executeUpdate() > 0;
        }
    }
}
