package com.booktrail.model;

import java.sql.Timestamp;

public class Book {
    private int id;
    private String title;
    private String author;
    private String genre;
    private int totalChapters;
    private String synopsis;
    private String coverUrl;
    private int publishedYear;
    private Timestamp createdAt;

    // Transient fields for discover/shelf stats
    private double averageRating;
    private int reviewCount;
    private String userShelfStatus; // e.g. WANT_TO_READ, CURRENTLY_READING, COMPLETED, or null
    private int userChaptersRead;

    public Book() {}

    public Book(int id, String title, String author, String genre, int totalChapters, String synopsis, String coverUrl, int publishedYear, Timestamp createdAt) {
        this.id = id;
        this.title = title;
        this.author = author;
        this.genre = genre;
        this.totalChapters = totalChapters;
        this.synopsis = synopsis;
        this.coverUrl = coverUrl;
        this.publishedYear = publishedYear;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public String getGenre() { return genre; }
    public void setGenre(String genre) { this.genre = genre; }

    public int getTotalChapters() { return totalChapters; }
    public void setTotalChapters(int totalChapters) { this.totalChapters = totalChapters; }

    public String getSynopsis() { return synopsis; }
    public void setSynopsis(String synopsis) { this.synopsis = synopsis; }

    public String getCoverUrl() { return coverUrl; }
    public void setCoverUrl(String coverUrl) { this.coverUrl = coverUrl; }

    public int getPublishedYear() { return publishedYear; }
    public void setPublishedYear(int publishedYear) { this.publishedYear = publishedYear; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public double getAverageRating() { return averageRating; }
    public void setAverageRating(double averageRating) { this.averageRating = averageRating; }

    public int getReviewCount() { return reviewCount; }
    public void setReviewCount(int reviewCount) { this.reviewCount = reviewCount; }

    public String getUserShelfStatus() { return userShelfStatus; }
    public void setUserShelfStatus(String userShelfStatus) { this.userShelfStatus = userShelfStatus; }

    public int getUserChaptersRead() { return userChaptersRead; }
    public void setUserChaptersRead(int userChaptersRead) { this.userChaptersRead = userChaptersRead; }
}
