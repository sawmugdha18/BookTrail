<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="${book.title} by ${book.author}" />
<c:set var="activePage" value="discover" />
<jsp:include page="includes/header.jsp" />

<!-- Breadcrumbs -->
<div style="margin-top: 20px; margin-bottom: 24px;">
    <a href="${pageContext.request.contextPath}/discover" style="color: var(--text-muted); font-size: 0.9rem; display: inline-flex; align-items: center; gap: 6px;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="19" y1="12" x2="5" y2="12"></line>
            <polyline points="12 19 5 12 12 5"></polyline>
        </svg>
        Back to Curated Shelves
    </a>
</div>

<!-- Main Book Detail Layout -->
<div class="book-detail-grid">
    <!-- Left Sidebar: Cover & Personal Reading Status -->
    <aside class="book-detail-sidebar">
        <div class="book-detail-cover">
            <img src="${book.coverUrl}" alt="${book.title}"
                 onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&auto=format&fit=crop&q=80'" />
        </div>

        <!-- Personal Reading Progress Card -->
        <div class="reading-status-card">
            <h3>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1-2.5-2.5Z"></path>
                </svg>
                My Reading Progress
            </h3>

            <c:choose>
                <c:when test="${sessionScope.currentUser != null}">
                    <form action="${pageContext.request.contextPath}/shelf/update" method="POST">
                        <input type="hidden" name="bookId" value="${book.id}" />
                        <input type="hidden" name="redirect" value="${pageContext.request.contextPath}/book?id=${book.id}" />

                        <div class="form-group" style="margin-bottom: 14px;">
                            <label class="form-label" for="shelfStatusSelect">Shelf Status</label>
                            <select id="shelfStatusSelect" name="status" class="form-control">
                                <option value="WANT_TO_READ" ${shelfItem != null && shelfItem.status == 'WANT_TO_READ' ? 'selected' : ''}>Want to Read</option>
                                <option value="CURRENTLY_READING" ${shelfItem != null && shelfItem.status == 'CURRENTLY_READING' ? 'selected' : ''}>Currently Reading</option>
                                <option value="COMPLETED" ${shelfItem != null && shelfItem.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                            </select>
                        </div>

                        <div class="form-group" style="margin-bottom: 14px;">
                            <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                                <label class="form-label" for="chaptersInput" style="margin: 0;">Chapters Read</label>
                                <span style="font-size: 0.84rem; color: var(--text-muted);" id="progressPercentLabel">
                                    <c:choose>
                                        <c:when test="${shelfItem != null}">${shelfItem.progressPercentage}%</c:when>
                                        <c:otherwise>0%</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <div style="display: flex; align-items: center; gap: 8px;">
                                <input type="number" id="chaptersInput" name="chaptersRead"
                                       class="form-control input-chapter-sync"
                                       min="0" max="${book.totalChapters}"
                                       value="${shelfItem != null ? shelfItem.chaptersRead : 0}"
                                       data-total="${book.totalChapters}"
                                       data-fill-id="progressBarDetail"
                                       data-label-id="progressPercentLabel" />
                                <span style="font-size: 0.9rem; color: var(--text-muted); white-space: nowrap;">/ ${book.totalChapters} ch.</span>
                            </div>

                            <div class="progress-track" style="margin-top: 10px;">
                                <div id="progressBarDetail" class="progress-bar-fill"
                                     style="width: ${shelfItem != null ? shelfItem.progressPercentage : 0}%;"></div>
                            </div>
                        </div>

                        <div class="form-group" style="margin-bottom: 16px;">
                            <label class="form-label" for="readingNotes">Personal Reading Notes (Optional)</label>
                            <textarea id="readingNotes" name="notes" class="form-control" rows="2" placeholder="Private reflections, page bookmarks...">${shelfItem != null ? shelfItem.notes : ''}</textarea>
                        </div>

                        <button type="submit" class="btn btn-primary" style="width: 100%;">
                            <c:choose>
                                <c:when test="${shelfItem != null}">Update Progress</c:when>
                                <c:otherwise>Save to My Bookshelf</c:otherwise>
                            </c:choose>
                        </button>
                    </form>
                </c:when>
                <c:otherwise>
                    <p style="font-size: 0.92rem; color: var(--text-secondary); line-height: 1.5; margin-bottom: 16px;">
                        Sign in to track your reading journey, log chapter progress, and unlock spoiler-free discussion rooms.
                    </p>
                    <div style="display: flex; flex-direction: column; gap: 8px;">
                        <a href="${pageContext.request.contextPath}/login?redirect=${pageContext.request.contextPath}/book?id=${book.id}" class="btn btn-secondary btn-sm" style="text-align: center;">Log in to Log Book</a>
                        <a href="${pageContext.request.contextPath}/register" class="btn btn-terracotta btn-sm" style="text-align: center;">Join BookTrail Free</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </aside>

    <!-- Right Main Column: Overview, Synopsis, Chapter Rooms & Reviews -->
    <main class="book-detail-main">
        <!-- Book Header Title & Meta -->
        <section class="book-header-section">
            <span class="badge badge-terracotta" style="margin-bottom: 10px;">${book.genre}</span>
            <h1 class="book-header-title">${book.title}</h1>
            <div class="book-header-author">by <strong>${book.author}</strong></div>

            <div class="book-metadata-pills">
                <span class="badge badge-sage">
                    ★ <c:choose><c:when test="${book.averageRating > 0}">${book.averageRating} Stars</c:when><c:otherwise>Not yet rated</c:otherwise></c:choose>
                    <c:if test="${book.reviewCount > 0}">(${book.reviewCount} ${book.reviewCount == 1 ? 'review' : 'reviews'})</c:if>
                </span>
                <span class="badge badge-gray">
                    ${book.totalChapters} Chapters
                </span>
                <span class="badge badge-gray">
                    Published in ${book.publishedYear}
                </span>
            </div>
        </section>

        <!-- Synopsis -->
        <section>
            <h2 style="font-size: 1.4rem; margin-bottom: 12px;">Synopsis &amp; Overview</h2>
            <p class="book-synopsis-text">${book.synopsis}</p>
        </section>

        <!-- Chapter Discussion Rooms Section (Section 7 & 10) -->
        <section class="book-rooms-section" aria-labelledby="chapter-rooms-title">
            <div class="book-rooms-header">
                <div>
                    <h2 id="chapter-rooms-title" style="font-size: 1.4rem; margin-bottom: 4px;">Spoiler-Safe Chapter Discussions</h2>
                    <p style="color: var(--text-muted); font-size: 0.9rem; margin: 0;">Discussion rooms partitioned by chapter ranges. Gated server-side based on your shelf progress.</p>
                </div>
            </div>

            <div class="book-rooms-list">
                <c:set var="userCh" value="${shelfItem != null ? shelfItem.chaptersRead : 0}" />

                <c:forEach var="room" items="${rooms}">
                    <c:set var="isSafe" value="${sessionScope.currentUser != null && userCh >= room.chapterEnd}" />

                    <div class="book-room-item">
                        <div style="flex: 1;">
                            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px; flex-wrap: wrap;">
                                <span class="badge badge-gray">Chapters ${room.chapterStart} &ndash; ${room.chapterEnd}</span>
                                <c:choose>
                                    <c:when test="${sessionScope.currentUser != null}">
                                        <c:choose>
                                            <c:when test="${isSafe}">
                                                <span class="badge badge-sage" title="You read up to Ch. ${userCh}">✓ Safe for you</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-amber" title="Covers up to Ch. ${room.chapterEnd}, you're on Ch. ${userCh}">🔒 Spoiler Gated</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-amber">🔒 Spoiler Protected</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <h3 style="font-size: 1.18rem; margin-bottom: 4px;">
                                <a href="${pageContext.request.contextPath}/room?id=${room.id}">${room.title}</a>
                            </h3>
                            <p style="color: var(--text-muted); font-size: 0.88rem; margin: 0;">${room.description}</p>
                        </div>

                        <div style="text-align: right; flex-shrink: 0;">
                            <div style="font-size: 0.82rem; color: var(--text-muted); margin-bottom: 6px;">
                                ${room.postCount} ${room.postCount == 1 ? 'discussion' : 'discussions'}
                            </div>
                            <a href="${pageContext.request.contextPath}/room?id=${room.id}" class="btn btn-secondary btn-sm">
                                Enter Room &rarr;
                            </a>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty rooms}">
                    <div style="text-align: center; padding: 24px; color: var(--text-muted); font-size: 0.92rem;">
                        No discussion rooms created for this book yet. Discussions open as readers begin reading groups.
                    </div>
                </c:if>
            </div>
        </section>

        <!-- Community Reviews & Ratings Section -->
        <section class="reviews-section" aria-labelledby="reviews-title">
            <h2 id="reviews-title" style="font-size: 1.4rem; margin-bottom: 16px;">
                Reader Reviews &amp; Reflections (${reviews.size()})
            </h2>

            <!-- Review submission form -->
            <c:choose>
                <c:when test="${sessionScope.currentUser != null}">
                    <div class="card" style="margin-bottom: 24px; background-color: var(--surface-elevated); padding: 20px;">
                        <h3 style="font-size: 1.15rem; margin-bottom: 12px;">Share Your Thoughts on this Book</h3>
                        <form action="${pageContext.request.contextPath}/review/save" method="POST">
                            <input type="hidden" name="bookId" value="${book.id}" />

                            <div class="form-group" style="margin-bottom: 12px;">
                                <label class="form-label" for="ratingSelect">Your Rating</label>
                                <select id="ratingSelect" name="rating" class="form-control" required style="max-width: 280px;">
                                    <option value="5">★★★★★ (5 Stars - Masterpiece)</option>
                                    <option value="4">★★★★☆ (4 Stars - Great Read)</option>
                                    <option value="3">★★★☆☆ (3 Stars - Enjoyable)</option>
                                    <option value="2">★★☆☆☆ (2 Stars - Mediocre)</option>
                                    <option value="1">★☆☆☆☆ (1 Star - Disappointing)</option>
                                </select>
                            </div>

                            <div class="form-group" style="margin-bottom: 14px;">
                                <label class="form-label" for="reviewBodyText">Your Written Review</label>
                                <textarea id="reviewBodyText" name="reviewText" class="form-control" rows="3" required placeholder="What feelings, questions, or impressions did this story leave you with?"></textarea>
                            </div>

                            <button type="submit" class="btn btn-primary btn-sm">Publish Review</button>
                        </form>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="padding: 16px 20px; background-color: var(--surface-elevated); border: 1px dashed var(--border-color); border-radius: var(--radius-md); margin-bottom: 24px; font-size: 0.92rem; color: var(--text-secondary);">
                        <a href="${pageContext.request.contextPath}/login?redirect=${pageContext.request.contextPath}/book?id=${book.id}" style="color: var(--accent-terracotta); font-weight: 600;">Sign in</a> to leave your review and star rating for ${book.title}.
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Reviews Stream -->
            <div class="reviews-list">
                <c:forEach var="rev" items="${reviews}">
                    <div class="review-card">
                        <div class="review-header">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span class="user-avatar" style="width: 26px; height: 26px; font-size: 0.75rem;">
                                    ${rev.authorUsername.substring(0, 1).toUpperCase()}
                                </span>
                                <span style="font-weight: 600; font-size: 0.95rem;">${rev.authorUsername}</span>
                                <span style="color: var(--text-muted); font-size: 0.82rem;">&bull; ${rev.createdAt}</span>
                            </div>
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <div class="review-stars">
                                    <c:forEach begin="1" end="${rev.rating}">★</c:forEach>
                                </div>
                                <c:if test="${sessionScope.currentUser != null && (sessionScope.currentUser.admin || sessionScope.currentUser.id == rev.userId)}">
                                    <form action="${pageContext.request.contextPath}/review/delete" method="POST" onsubmit="return confirm('Delete this review?');" style="margin: 0;">
                                        <input type="hidden" name="reviewId" value="${rev.id}" />
                                        <input type="hidden" name="redirect" value="${pageContext.request.contextPath}/book?id=${book.id}" />
                                        <button type="submit" class="btn btn-subtle btn-sm" style="color: #A33A3A; padding: 2px 6px; font-size: 0.75rem;" title="Delete review">
                                            Delete
                                        </button>
                                    </form>
                                </c:if>
                            </div>
                        </div>
                        <p style="font-size: 0.95rem; line-height: 1.6; color: var(--text-primary); margin: 0;">
                            <c:out value="${rev.reviewText}" />
                        </p>
                    </div>
                </c:forEach>

                <c:if test="${empty reviews}">
                    <div style="text-align: center; padding: 24px; color: var(--text-muted); font-size: 0.92rem;">
                        No reviews published for this title yet. Be the first reader to share your reflection.
                    </div>
                </c:if>
            </div>
        </section>
    </main>
</div>

<jsp:include page="includes/footer.jsp" />
