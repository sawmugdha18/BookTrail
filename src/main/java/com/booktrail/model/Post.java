package com.booktrail.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Post {
    private int id;
    private int roomId;
    private int userId;
    private String title;
    private String content;
    private boolean hasSpoilers;
    private Timestamp createdAt;

    // Joined metadata
    private String authorUsername;
    private String authorBio;
    private int commentCount;
    private List<Comment> comments = new ArrayList<>();

    public Post() {}

    public Post(int id, int roomId, int userId, String title, String content, boolean hasSpoilers, Timestamp createdAt) {
        this.id = id;
        this.roomId = roomId;
        this.userId = userId;
        this.title = title;
        this.content = content;
        this.hasSpoilers = hasSpoilers;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public boolean isHasSpoilers() { return hasSpoilers; }
    public void setHasSpoilers(boolean hasSpoilers) { this.hasSpoilers = hasSpoilers; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getAuthorUsername() { return authorUsername; }
    public void setAuthorUsername(String authorUsername) { this.authorUsername = authorUsername; }

    public String getAuthorBio() { return authorBio; }
    public void setAuthorBio(String authorBio) { this.authorBio = authorBio; }

    public int getCommentCount() { return commentCount; }
    public void setCommentCount(int commentCount) { this.commentCount = commentCount; }

    public List<Comment> getComments() { return comments; }
    public void setComments(List<Comment> comments) { this.comments = comments; }
}
