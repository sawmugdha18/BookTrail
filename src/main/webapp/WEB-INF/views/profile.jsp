<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Reader Profile &amp; Journal" />
<c:set var="activePage" value="profile" />
<jsp:include page="includes/header.jsp" />

<div class="page-header" style="margin-top: 24px;">
    <h1 class="page-title">Reader Journal &amp; Profile</h1>
    <p class="page-subtitle">Your personal reading milestones, statistics, and published literary reflections.</p>
</div>

<!-- Profile Info Card -->
<div class="card" style="margin-bottom: 32px;">
    <div style="display: flex; gap: 24px; align-items: flex-start; flex-wrap: wrap;">
        <div class="user-avatar" style="width: 68px; height: 68px; font-size: 2rem; flex-shrink: 0;">
            ${sessionScope.currentUser.username.substring(0, 1).toUpperCase()}
        </div>

        <div style="flex: 1; min-width: 260px;">
            <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px; flex-wrap: wrap;">
                <h2 style="font-size: 1.8rem; margin: 0;">${sessionScope.currentUser.username}</h2>
                <span class="badge ${sessionScope.currentUser.admin ? 'badge-amber' : 'badge-sage'}">
                    ${sessionScope.currentUser.role}
                </span>
            </div>
            <div style="color: var(--text-muted); font-size: 0.88rem; margin-bottom: 16px;">
                ${sessionScope.currentUser.email} &bull; Member since ${sessionScope.currentUser.createdAt}
            </div>

            <!-- Editable Bio Form -->
            <form action="${pageContext.request.contextPath}/profile/bio" method="POST" style="max-width: 600px;">
                <label class="form-label" for="bioInput" style="font-size: 0.85rem;">Reader Bio</label>
                <div style="display: flex; gap: 8px;">
                    <input type="text" id="bioInput" name="bio" class="form-control"
                           value="<c:out value="${sessionScope.currentUser.bio}" />"
                           placeholder="Add a line about your favorite genres or reading ritual..." />
                    <button type="submit" class="btn btn-secondary btn-sm" style="flex-shrink: 0;">Save Bio</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Stats Counter Grid -->
<div class="shelf-metrics-grid" style="margin-bottom: 36px;">
    <div class="metric-card">
        <span class="metric-label">Books Finished</span>
        <div class="metric-value">${stats[0]}</div>
    </div>
    <div class="metric-card">
        <span class="metric-label">Total Chapters Read</span>
        <div class="metric-value">${stats[1]}</div>
    </div>
    <div class="metric-card">
        <span class="metric-label">Currently Reading</span>
        <div class="metric-value" style="color: var(--accent-terracotta);">${stats[2]}</div>
    </div>
    <div class="metric-card">
        <span class="metric-label">Reviews Published</span>
        <div class="metric-value">${userReviews.size()}</div>
    </div>
</div>

<!-- Two-Column Review Layout -->
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 32px; margin-bottom: 48px;">
    <!-- Write a Review Form -->
    <section class="card" aria-labelledby="write-review-heading">
        <h2 id="write-review-heading" style="font-size: 1.35rem; margin-bottom: 16px;">
            Publish a Book Reflection
        </h2>

        <form action="${pageContext.request.contextPath}/review/save" method="POST">
            <div class="form-group">
                <label class="form-label" for="bookSelect">Select Book</label>
                <select id="bookSelect" name="bookId" class="form-control" required>
                    <c:forEach var="b" items="${allBooks}">
                        <option value="${b.id}">${b.title} by ${b.author}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label" for="ratingSelect">Star Rating</label>
                <select id="ratingSelect" name="rating" class="form-control" required>
                    <option value="5">★★★★★ (5 Stars - Masterpiece)</option>
                    <option value="4">★★★★☆ (4 Stars - Highly Recommended)</option>
                    <option value="3">★★★☆☆ (3 Stars - Enjoyable)</option>
                    <option value="2">★★☆☆☆ (2 Stars - Mediocre)</option>
                    <option value="1">★☆☆☆☆ (1 Star - Disappointing)</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label" for="reviewBody">Your Written Review</label>
                <textarea id="reviewBody" name="reviewText" class="form-control" rows="4" required
                          placeholder="What thoughts or emotions did this story evoke? What themes resonated with you?"></textarea>
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%;">
                Publish Review
            </button>
        </form>
    </section>

    <!-- My Published Reviews List -->
    <section aria-labelledby="my-reviews-heading">
        <h2 id="my-reviews-heading" style="font-size: 1.35rem; margin-bottom: 16px;">
            My Published Reviews (${userReviews.size()})
        </h2>

        <div style="display: flex; flex-direction: column; gap: 16px;">
            <c:forEach var="rev" items="${userReviews}">
                <article class="card" style="padding: 20px;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
                        <div>
                            <h3 style="font-size: 1.15rem; margin-bottom: 2px;">
                                <a href="${pageContext.request.contextPath}/book?id=${rev.bookId}" style="color: var(--text-primary);">
                                    ${rev.bookTitle}
                                </a>
                            </h3>
                            <div style="font-size: 0.84rem; color: var(--text-muted);">
                                by ${rev.bookAuthor} &bull; ${rev.createdAt}
                            </div>
                        </div>

                        <div style="display: flex; align-items: center; gap: 10px;">
                            <div style="color: #D48806; font-size: 0.95rem; letter-spacing: 2px;">
                                <c:forEach begin="1" end="${rev.rating}">★</c:forEach>
                            </div>
                            <form action="${pageContext.request.contextPath}/review/delete" method="POST" onsubmit="return confirm('Delete this review?');" style="margin: 0;">
                                <input type="hidden" name="reviewId" value="${rev.id}" />
                                <button type="submit" class="btn btn-subtle btn-sm" style="color: #A33A3A; padding: 2px 8px; font-size: 0.78rem;" title="Delete review">
                                    Delete
                                </button>
                            </form>
                        </div>
                    </div>

                    <p style="font-size: 0.92rem; line-height: 1.6; color: var(--text-secondary); margin: 0;">
                        <c:out value="${rev.reviewText}" />
                    </p>
                </article>
            </c:forEach>

            <c:if test="${empty userReviews}">
                <div class="empty-state" style="margin: 0; padding: 36px 20px;">
                    <div class="empty-state-icon" style="font-size: 2rem;">✍️</div>
                    <h3 style="font-size: 1.2rem; margin-bottom: 6px;">No published reviews yet</h3>
                    <p style="font-size: 0.88rem; color: var(--text-muted); margin: 0;">
                        Once you finish a book, publish your impressions using the form on the left.
                    </p>
                </div>
            </c:if>
        </div>
    </section>
</div>

<!-- Completed Books Shelf -->
<section class="card" style="margin-bottom: 48px;" aria-labelledby="completed-heading">
    <h2 id="completed-heading" style="font-size: 1.35rem; margin-bottom: 16px;">
        Finished Stories (${completedBooks.size()})
    </h2>

    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(130px, 1fr)); gap: 18px;">
        <c:forEach var="cBook" items="${completedBooks}">
            <a href="${pageContext.request.contextPath}/book?id=${cBook.bookId}" style="display: block; text-decoration: none;" title="${cBook.book.title}">
                <div style="aspect-ratio: 2 / 3; border-radius: var(--radius-sm); overflow: hidden; box-shadow: var(--shadow-sm); margin-bottom: 8px;">
                    <img src="${cBook.book.coverUrl}" alt="${cBook.book.title}" style="width: 100%; height: 100%; object-fit: cover;"
                         onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&auto=format&fit=crop&q=80'" />
                </div>
                <div style="font-size: 0.86rem; font-weight: 600; color: var(--text-primary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                    ${cBook.book.title}
                </div>
                <div style="font-size: 0.78rem; color: var(--text-muted);">
                    ${cBook.book.author}
                </div>
            </a>
        </c:forEach>

        <c:if test="${empty completedBooks}">
            <p style="color: var(--text-muted); font-size: 0.92rem; grid-column: 1 / -1; margin: 0;">
                No books marked as completed yet. As you finish titles, they will populate your completed shelf.
            </p>
        </c:if>
    </div>
</section>

<jsp:include page="includes/footer.jsp" />
