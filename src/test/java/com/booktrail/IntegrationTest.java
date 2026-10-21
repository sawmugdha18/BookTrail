package com.booktrail;

import com.booktrail.config.DBConnection;
import com.booktrail.dao.BookDAO;
import com.booktrail.dao.BookshelfDAO;
import com.booktrail.dao.DiscussionDAO;
import com.booktrail.dao.ReviewDAO;
import com.booktrail.dao.UserDAO;
import com.booktrail.model.Book;
import com.booktrail.model.BookshelfItem;
import com.booktrail.model.Comment;
import com.booktrail.model.DiscussionRoom;
import com.booktrail.model.Post;
import com.booktrail.model.Review;
import com.booktrail.model.User;
import com.booktrail.util.PasswordUtil;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class IntegrationTest {

    private static UserDAO userDAO;
    private static BookDAO bookDAO;
    private static BookshelfDAO bookshelfDAO;
    private static DiscussionDAO discussionDAO;
    private static ReviewDAO reviewDAO;

    private static User testReader;
    private static Book testBook;
    private static int createdPostId;
    private static int createdCommentId;
    private static int createdReviewId;

    @BeforeAll
    public static void setup() throws SQLException {
        // Trigger database connectivity & seed initialization
        try (Connection conn = DBConnection.getConnection()) {
            assertNotNull(conn, "Database connection must not be null");
        }

        userDAO = new UserDAO();
        bookDAO = new BookDAO();
        bookshelfDAO = new BookshelfDAO();
        discussionDAO = new DiscussionDAO();
        reviewDAO = new ReviewDAO();
    }

    @Test
    @Order(1)
    public void testAuthenticationAndUserDAO() throws SQLException {
        // Test seeded user retrieval & salted SHA-256 verification
        User elena = userDAO.findByUsername("elena_reader");
        assertNotNull(elena, "Elena should exist in seeded database");
        assertEquals("elena_reader", elena.getUsername());
        assertFalse(elena.isAdmin());

        boolean validAuth = PasswordUtil.verifyPassword("password123", elena.getSalt(), elena.getPasswordHash());
        assertTrue(validAuth, "Seeded password should verify with salted hash");

        boolean invalidAuth = PasswordUtil.verifyPassword("wrongPassword", elena.getSalt(), elena.getPasswordHash());
        assertFalse(invalidAuth, "Incorrect password should be rejected");

        // Test admin user
        User admin = userDAO.findByUsername("admin");
        assertNotNull(admin, "Admin should exist in seeded database");
        assertTrue(admin.isAdmin());

        // Test registering a new test user
        String uniqueUsername = "test_reader_" + System.currentTimeMillis();
        String salt = PasswordUtil.generateSalt();
        String hash = PasswordUtil.hashPassword("securePass!23", salt);

        User newUser = new User();
        newUser.setUsername(uniqueUsername);
        newUser.setEmail(uniqueUsername + "@mountaincafe.test");
        newUser.setPasswordHash(hash);
        newUser.setSalt(salt);
        newUser.setRole("READER");
        newUser.setBio("Initial bio");

        boolean created = userDAO.create(newUser);
        assertTrue(created, "User creation should succeed");

        testReader = userDAO.findByUsername(uniqueUsername);
        assertNotNull(testReader);
        assertEquals(uniqueUsername, testReader.getUsername());

        // Test bio update
        userDAO.updateBio(testReader.getId(), "Avid reader of misty mountain fiction.");
        User refreshed = userDAO.findById(testReader.getId());
        assertEquals("Avid reader of misty mountain fiction.", refreshed.getBio());
    }

    @Test
    @Order(2)
    public void testBookDAOAndCatalogDiscovery() throws SQLException {
        List<Book> allBooks = bookDAO.getAllBooks(0);
        assertNotNull(allBooks);
        assertFalse(allBooks.isEmpty(), "Book catalog should have seeded books");

        testBook = allBooks.get(0);
        assertNotNull(testBook.getTitle());
        assertTrue(testBook.getTotalChapters() > 0, "Book should have chapters defined");

        // Test findById
        Book fetched = bookDAO.findById(testBook.getId(), 0);
        assertNotNull(fetched);
        assertEquals(testBook.getTitle(), fetched.getTitle());

        // Test search
        List<Book> searchResults = bookDAO.searchBooks(testBook.getTitle().substring(0, 3), null, 0);
        assertFalse(searchResults.isEmpty(), "Search should find book matching substring");

        // Test genre filter
        List<String> genres = bookDAO.getGenres();
        assertNotNull(genres);
        assertFalse(genres.isEmpty(), "Genres should be available");
    }

    @Test
    @Order(3)
    public void testShelfProgressAndStatusAutomation() throws SQLException {
        assertNotNull(testReader);
        assertNotNull(testBook);

        // Add to shelf as CURRENTLY_READING
        bookshelfDAO.upsertShelfItem(testReader.getId(), testBook.getId(), "CURRENTLY_READING", 0, "Morning reading project");

        BookshelfItem item = bookshelfDAO.getItem(testReader.getId(), testBook.getId());
        assertNotNull(item, "Book should be in reader's shelf");
        assertEquals(0, item.getChaptersRead());
        assertEquals("CURRENTLY_READING", item.getStatus());

        // Update progress to halfway
        int halfway = testBook.getTotalChapters() / 2;
        bookshelfDAO.updateChaptersRead(testReader.getId(), testBook.getId(), halfway);

        BookshelfItem halfwayItem = bookshelfDAO.getItem(testReader.getId(), testBook.getId());
        assertEquals(halfway, halfwayItem.getChaptersRead());

        // Test completion status transition when chapters read reaches total chapters
        bookshelfDAO.updateChaptersRead(testReader.getId(), testBook.getId(), testBook.getTotalChapters());
        BookshelfItem completedItem = bookshelfDAO.getItem(testReader.getId(), testBook.getId());
        assertEquals(testBook.getTotalChapters(), completedItem.getChaptersRead());
        assertEquals("COMPLETED", completedItem.getStatus());
        assertEquals(100, completedItem.getProgressPercentage());

        // Test user reading statistics: [completedBooks, totalChaptersRead, currentlyReading, wantToRead]
        int[] stats = bookshelfDAO.getUserStats(testReader.getId());
        assertNotNull(stats);
        assertEquals(4, stats.length);
        assertEquals(1, stats[0], "Finished books count should be 1");
        assertEquals(testBook.getTotalChapters(), stats[1], "Total chapters read should match finished book chapters");
    }

    @Test
    @Order(4)
    public void testDiscussionRoomsPostsAndOwnership() throws SQLException {
        assertNotNull(testBook);
        assertNotNull(testReader);

        List<DiscussionRoom> rooms = discussionDAO.getRoomsForBook(testBook.getId());
        assertNotNull(rooms);
        assertFalse(rooms.isEmpty(), "Book should have at least one chapter discussion room");

        DiscussionRoom room = rooms.get(0);

        // Create a new post by testReader
        Post post = new Post();
        post.setRoomId(room.getId());
        post.setUserId(testReader.getId());
        post.setTitle("The imagery in chapter " + room.getChapterStart());
        post.setContent("The descriptions of the misty pine forests are remarkable.");
        post.setHasSpoilers(false);

        boolean postCreated = discussionDAO.createPost(post);
        assertTrue(postCreated, "Post should be successfully created");

        List<Post> posts = discussionDAO.getPostsForRoom(room.getId());
        assertFalse(posts.isEmpty());

        Post retrievedPost = posts.stream()
                .filter(p -> p.getTitle().equals(post.getTitle()))
                .findFirst()
                .orElse(null);
        assertNotNull(retrievedPost);
        createdPostId = retrievedPost.getId();
        assertEquals(testReader.getId(), retrievedPost.getUserId());

        // Verify getPostById helper
        Post singlePost = discussionDAO.getPostById(createdPostId);
        assertNotNull(singlePost);
        assertEquals(retrievedPost.getTitle(), singlePost.getTitle());

        // Create comment on the post
        Comment comment = new Comment();
        comment.setPostId(createdPostId);
        comment.setUserId(testReader.getId());
        comment.setContent("I completely agree with this reflection!");
        boolean commentCreated = discussionDAO.createComment(comment);
        assertTrue(commentCreated, "Comment should be created");

        // Verify comment retrieval
        List<Post> refreshedPosts = discussionDAO.getPostsForRoom(room.getId());
        Post postWithComments = refreshedPosts.stream()
                .filter(p -> p.getId() == createdPostId)
                .findFirst()
                .orElse(null);
        assertNotNull(postWithComments);
        assertFalse(postWithComments.getComments().isEmpty(), "Post should contain comments");

        Comment createdComment = postWithComments.getComments().get(0);
        createdCommentId = createdComment.getId();

        // Verify getCommentById helper
        Comment singleComment = discussionDAO.getCommentById(createdCommentId);
        assertNotNull(singleComment);
        assertEquals(createdComment.getContent(), singleComment.getContent());

        // Test delete comment
        boolean commentDeleted = discussionDAO.deleteComment(createdCommentId);
        assertTrue(commentDeleted, "Comment should be deleted");
        assertNull(discussionDAO.getCommentById(createdCommentId), "Deleted comment should no longer exist");

        // Test delete post
        boolean postDeleted = discussionDAO.deletePost(createdPostId);
        assertTrue(postDeleted, "Post should be deleted");
        assertNull(discussionDAO.getPostById(createdPostId), "Deleted post should no longer exist");
    }

    @Test
    @Order(5)
    public void testReviewCreationAndIdorProtection() throws SQLException {
        assertNotNull(testReader);
        assertNotNull(testBook);

        Review review = new Review();
        review.setBookId(testBook.getId());
        review.setUserId(testReader.getId());
        review.setRating(5);
        review.setReviewText("An evocative masterpiece that invites quiet contemplation.");

        boolean saved = reviewDAO.upsertReview(review);
        assertTrue(saved, "Review should be saved or upserted");

        List<Review> userReviews = reviewDAO.getReviewsByUser(testReader.getId());
        assertFalse(userReviews.isEmpty(), "User should have at least 1 published review");

        Review retrieved = userReviews.stream()
                .filter(r -> r.getBookId() == testBook.getId())
                .findFirst()
                .orElse(null);
        assertNotNull(retrieved);
        createdReviewId = retrieved.getId();
        assertEquals(5, retrieved.getRating());

        // Test IDOR ownership verification via getReviewById
        Review reviewForCheck = reviewDAO.getReviewById(createdReviewId);
        assertNotNull(reviewForCheck);
        assertEquals(testReader.getId(), reviewForCheck.getUserId());

        // Delete review
        boolean deleted = reviewDAO.deleteReview(createdReviewId);
        assertTrue(deleted, "Review should be successfully deleted");
        assertNull(reviewDAO.getReviewById(createdReviewId), "Deleted review should return null");
    }
}
