package com.booktrail.dao;

import com.booktrail.config.DBConnection;
import com.booktrail.model.Book;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class BookDAO {

    public List<Book> getAllBooks(int currentUserId) throws SQLException {
        return searchBooks(null, null, currentUserId);
    }

    public List<Book> searchBooks(String query, String genre, int currentUserId) throws SQLException {
        List<Book> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT b.id, b.title, b.author, b.genre, b.total_chapters, b.synopsis, b.cover_url, b.published_year, b.created_at, ")
           .append("COALESCE(AVG(r.rating), 0.0) AS avg_rating, COUNT(r.id) AS review_count, ")
           .append("s.status AS user_status, COALESCE(s.chapters_read, 0) AS user_chapters ")
           .append("FROM books b ")
           .append("LEFT JOIN reviews r ON b.id = r.book_id ")
           .append("LEFT JOIN user_bookshelf s ON b.id = s.book_id AND s.user_id = ? ")
           .append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        params.add(currentUserId);

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (LOWER(b.title) LIKE ? OR LOWER(b.author) LIKE ?) ");
            String q = "%" + query.trim().toLowerCase() + "%";
            params.add(q);
            params.add(q);
        }

        if (genre != null && !genre.trim().isEmpty() && !"ALL".equalsIgnoreCase(genre.trim())) {
            sql.append("AND LOWER(b.genre) = ? ");
            params.add(genre.trim().toLowerCase());
        }

        sql.append("GROUP BY b.id, b.title, b.author, b.genre, b.total_chapters, b.synopsis, b.cover_url, b.published_year, b.created_at, s.status, s.chapters_read ")
           .append("ORDER BY b.id ASC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public Book findById(int id, int currentUserId) throws SQLException {
        String sql = "SELECT b.id, b.title, b.author, b.genre, b.total_chapters, b.synopsis, b.cover_url, b.published_year, b.created_at, " +
                     "COALESCE(AVG(r.rating), 0.0) AS avg_rating, COUNT(r.id) AS review_count, " +
                     "s.status AS user_status, COALESCE(s.chapters_read, 0) AS user_chapters " +
                     "FROM books b " +
                     "LEFT JOIN reviews r ON b.id = r.book_id " +
                     "LEFT JOIN user_bookshelf s ON b.id = s.book_id AND s.user_id = ? " +
                     "WHERE b.id = ? " +
                     "GROUP BY b.id, b.title, b.author, b.genre, b.total_chapters, b.synopsis, b.cover_url, b.published_year, b.created_at, s.status, s.chapters_read";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            ps.setInt(2, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public List<String> getGenres() throws SQLException {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT genre FROM books WHERE genre IS NOT NULL AND genre <> '' ORDER BY genre ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("genre"));
            }
        }
        return list;
    }

    public boolean create(Book book) throws SQLException {
        String sql = "INSERT INTO books (title, author, genre, total_chapters, synopsis, cover_url, published_year) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, book.getTitle());
            ps.setString(2, book.getAuthor());
            ps.setString(3, book.getGenre());
            ps.setInt(4, book.getTotalChapters());
            ps.setString(5, book.getSynopsis());
            ps.setString(6, book.getCoverUrl());
            ps.setInt(7, book.getPublishedYear());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        book.setId(keys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }

    public boolean delete(int bookId) throws SQLException {
        String sql = "DELETE FROM books WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            return ps.executeUpdate() > 0;
        }
    }

    private Book mapRow(ResultSet rs) throws SQLException {
        Book b = new Book(
                rs.getInt("id"),
                rs.getString("title"),
                rs.getString("author"),
                rs.getString("genre"),
                rs.getInt("total_chapters"),
                rs.getString("synopsis"),
                rs.getString("cover_url"),
                rs.getInt("published_year"),
                rs.getTimestamp("created_at")
        );
        b.setAverageRating(Math.round(rs.getDouble("avg_rating") * 10.0) / 10.0);
        b.setReviewCount(rs.getInt("review_count"));
        b.setUserShelfStatus(rs.getString("user_status"));
        b.setUserChaptersRead(rs.getInt("user_chapters"));
        return b;
    }
}
