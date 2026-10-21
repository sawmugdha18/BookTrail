package com.booktrail.dao;

import com.booktrail.config.DBConnection;
import com.booktrail.model.Book;
import com.booktrail.model.BookshelfItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class BookshelfDAO {

    public List<BookshelfItem> getBookshelf(int userId, String statusFilter) throws SQLException {
        List<BookshelfItem> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT s.id, s.user_id, s.book_id, s.status, s.chapters_read, s.notes, s.updated_at, ")
           .append("b.title, b.author, b.genre, b.total_chapters, b.synopsis, b.cover_url, b.published_year, b.created_at AS book_created_at ")
           .append("FROM user_bookshelf s ")
           .append("JOIN books b ON s.book_id = b.id ")
           .append("WHERE s.user_id = ? ");

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append("AND s.status = ? ");
        }

        sql.append("ORDER BY s.updated_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, userId);
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
                ps.setString(2, statusFilter.trim().toUpperCase());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookshelfItem item = new BookshelfItem(
                            rs.getInt("id"),
                            rs.getInt("user_id"),
                            rs.getInt("book_id"),
                            rs.getString("status"),
                            rs.getInt("chapters_read"),
                            rs.getString("notes"),
                            rs.getTimestamp("updated_at")
                    );
                    Book book = new Book(
                            rs.getInt("book_id"),
                            rs.getString("title"),
                            rs.getString("author"),
                            rs.getString("genre"),
                            rs.getInt("total_chapters"),
                            rs.getString("synopsis"),
                            rs.getString("cover_url"),
                            rs.getInt("published_year"),
                            rs.getTimestamp("book_created_at")
                    );
                    item.setBook(book);
                    list.add(item);
                }
            }
        }
        return list;
    }

    public BookshelfItem getItem(int userId, int bookId) throws SQLException {
        String sql = "SELECT s.id, s.user_id, s.book_id, s.status, s.chapters_read, s.notes, s.updated_at, " +
                     "b.title, b.author, b.genre, b.total_chapters, b.synopsis, b.cover_url, b.published_year, b.created_at AS book_created_at " +
                     "FROM user_bookshelf s " +
                     "JOIN books b ON s.book_id = b.id " +
                     "WHERE s.user_id = ? AND s.book_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, bookId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BookshelfItem item = new BookshelfItem(
                            rs.getInt("id"),
                            rs.getInt("user_id"),
                            rs.getInt("book_id"),
                            rs.getString("status"),
                            rs.getInt("chapters_read"),
                            rs.getString("notes"),
                            rs.getTimestamp("updated_at")
                    );
                    Book book = new Book(
                            rs.getInt("book_id"),
                            rs.getString("title"),
                            rs.getString("author"),
                            rs.getString("genre"),
                            rs.getInt("total_chapters"),
                            rs.getString("synopsis"),
                            rs.getString("cover_url"),
                            rs.getInt("published_year"),
                            rs.getTimestamp("book_created_at")
                    );
                    item.setBook(book);
                    return item;
                }
            }
        }
        return null;
    }

    public boolean upsertShelfItem(int userId, int bookId, String status, int chaptersRead, String notes) throws SQLException {
        BookshelfItem existing = getItem(userId, bookId);
        if (existing == null) {
            String sql = "INSERT INTO user_bookshelf (user_id, book_id, status, chapters_read, notes) VALUES (?, ?, ?, ?, ?)";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, bookId);
                ps.setString(3, status);
                ps.setInt(4, chaptersRead);
                ps.setString(5, notes != null ? notes : "");
                return ps.executeUpdate() > 0;
            }
        } else {
            String sql = "UPDATE user_bookshelf SET status = ?, chapters_read = ?, notes = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ? AND book_id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                ps.setInt(2, chaptersRead);
                ps.setString(3, notes != null ? notes : existing.getNotes());
                ps.setInt(4, userId);
                ps.setInt(5, bookId);
                return ps.executeUpdate() > 0;
            }
        }
    }

    public boolean updateChaptersRead(int userId, int bookId, int chaptersRead) throws SQLException {
        BookshelfItem existing = getItem(userId, bookId);
        if (existing == null) {
            return upsertShelfItem(userId, bookId, "CURRENTLY_READING", chaptersRead, "");
        }

        String newStatus = existing.getStatus();
        if (existing.getBook() != null && chaptersRead >= existing.getBook().getTotalChapters()) {
            newStatus = "COMPLETED";
            chaptersRead = existing.getBook().getTotalChapters();
        } else if ("WANT_TO_READ".equals(newStatus) && chaptersRead > 0) {
            newStatus = "CURRENTLY_READING";
        }

        String sql = "UPDATE user_bookshelf SET chapters_read = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ? AND book_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, chaptersRead);
            ps.setString(2, newStatus);
            ps.setInt(3, userId);
            ps.setInt(4, bookId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean removeFromShelf(int userId, int bookId) throws SQLException {
        String sql = "DELETE FROM user_bookshelf WHERE user_id = ? AND book_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, bookId);
            return ps.executeUpdate() > 0;
        }
    }

    public int[] getUserStats(int userId) throws SQLException {
        // [completedBooks, totalChaptersRead, currentlyReading, wantToRead]
        int[] stats = new int[4];
        String sql = "SELECT status, COUNT(*) AS cnt, SUM(chapters_read) AS ch_sum FROM user_bookshelf WHERE user_id = ? GROUP BY status";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String status = rs.getString("status");
                    int count = rs.getInt("cnt");
                    int chapters = rs.getInt("ch_sum");
                    stats[1] += chapters; // accumulate total chapters read
                    if ("COMPLETED".equalsIgnoreCase(status)) {
                        stats[0] = count;
                    } else if ("CURRENTLY_READING".equalsIgnoreCase(status)) {
                        stats[2] = count;
                    } else if ("WANT_TO_READ".equalsIgnoreCase(status)) {
                        stats[3] = count;
                    }
                }
            }
        }
        return stats;
    }
}
