package com.booktrail.model;

import java.sql.Timestamp;

public class DiscussionRoom {
    private int id;
    private int bookId;
    private String title;
    private int chapterStart;
    private int chapterEnd;
    private String description;
    private Timestamp createdAt;

    // Joined Book entity & stats
    private Book book;
    private int postCount;

    public DiscussionRoom() {}

    public DiscussionRoom(int id, int bookId, String title, int chapterStart, int chapterEnd, String description, Timestamp createdAt) {
        this.id = id;
        this.bookId = bookId;
        this.title = title;
        this.chapterStart = chapterStart;
        this.chapterEnd = chapterEnd;
        this.description = description;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public int getChapterStart() { return chapterStart; }
    public void setChapterStart(int chapterStart) { this.chapterStart = chapterStart; }

    public int getChapterEnd() { return chapterEnd; }
    public void setChapterEnd(int chapterEnd) { this.chapterEnd = chapterEnd; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Book getBook() { return book; }
    public void setBook(Book book) { this.book = book; }

    public int getPostCount() { return postCount; }
    public void setPostCount(int postCount) { this.postCount = postCount; }
}
