package com.booktrail.model;

import java.sql.Timestamp;

public class BookshelfItem {
    private int id;
    private int userId;
    private int bookId;
    private String status; // 'WANT_TO_READ', 'CURRENTLY_READING', 'COMPLETED'
    private int chaptersRead;
    private String notes;
    private Timestamp updatedAt;

    // Joined Book entity
    private Book book;

    public BookshelfItem() {}

    public BookshelfItem(int id, int userId, int bookId, String status, int chaptersRead, String notes, Timestamp updatedAt) {
        this.id = id;
        this.userId = userId;
        this.bookId = bookId;
        this.status = status;
        this.chaptersRead = chaptersRead;
        this.notes = notes;
        this.updatedAt = updatedAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getChaptersRead() { return chaptersRead; }
    public void setChaptersRead(int chaptersRead) { this.chaptersRead = chaptersRead; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public Book getBook() { return book; }
    public void setBook(Book book) { this.book = book; }

    public int getProgressPercentage() {
        if (book == null || book.getTotalChapters() <= 0) {
            return 0;
        }
        int pct = (int) Math.round(((double) chaptersRead / book.getTotalChapters()) * 100);
        return Math.min(100, Math.max(0, pct));
    }
}
