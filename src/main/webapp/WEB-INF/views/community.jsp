<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="The Reading Table — Community Rooms" />
<c:set var="activePage" value="community" />
<jsp:include page="includes/header.jsp" />

<!-- Communal Reading Table Banner -->
<section class="reading-corner-banner" style="margin-top: 24px; min-height: 250px;" aria-label="The Communal Reading Table">
    <img src="${pageContext.request.contextPath}/static/images/communal-table.jpg"
         alt="Readers gathered at the communal library table"
         class="reading-corner-bg" />
    <div class="reading-corner-overlay"></div>
    <div class="reading-corner-banner-content">
        <div class="hero-badge" style="margin-bottom: 12px;">The Communal Table</div>
        <h1 style="color: #FFFFFF; font-size: clamp(1.8rem, 3.2vw, 2.5rem); margin-bottom: 8px;">
            Spoiler-Safe Chapter Rooms
        </h1>
        <p style="color: #E2ECE5; font-size: 1.02rem; line-height: 1.6;">
            Pull up a chair. Every discussion room is strictly bounded by chapter milestones. Your progress governs what you see, keeping every twist preserved until you turn the page.
        </p>
    </div>
</section>

<!-- Book Filter Bar -->
<div class="filter-bar" style="margin-top: 32px;">
    <div style="font-weight: 600; font-size: 0.9rem; color: var(--text-secondary);">Filter Rooms by Book:</div>
    <div class="mood-pills" style="margin-top: 0;">
        <a href="${pageContext.request.contextPath}/community" class="mood-pill ${selectedBookId == null ? 'active' : ''}">
            <span>📚</span>
            <span>All Books</span>
        </a>
        <c:forEach var="b" items="${books}">
            <a href="${pageContext.request.contextPath}/community?bookId=${b.id}" class="mood-pill ${selectedBookId == b.id ? 'active' : ''}">
                <span>${b.title}</span>
            </a>
        </c:forEach>
    </div>
</div>

<!-- Discussion Rooms Grid -->
<div class="discussions-preview-grid" style="margin-bottom: 48px;">
    <c:forEach var="room" items="${rooms}">
        <c:set var="userCh" value="${userProgressMap[room.bookId] != null ? userProgressMap[room.bookId] : 0}" />
        <c:set var="isSafe" value="${sessionScope.currentUser != null && userCh >= room.chapterEnd}" />

        <article class="discussion-card">
            <div style="display: flex; gap: 14px; margin-bottom: 12px; align-items: center;">
                <img src="${room.book.coverUrl}" alt="${room.book.title}"
                     style="width: 44px; height: 66px; object-fit: cover; border-radius: 4px; box-shadow: var(--shadow-sm); flex-shrink: 0;"
                     onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&auto=format&fit=crop&q=80'" />
                <div style="flex: 1; min-width: 0;">
                    <div style="font-size: 0.8rem; color: var(--accent-terracotta); font-weight: 600; text-transform: uppercase;">
                        ${room.book.genre}
                    </div>
                    <div style="font-weight: 600; font-size: 0.95rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                        ${room.book.title}
                    </div>
                    <div style="font-size: 0.82rem; color: var(--text-muted);">
                        by ${room.book.author}
                    </div>
                </div>
            </div>

            <div style="display: flex; gap: 8px; align-items: center; margin-bottom: 12px; flex-wrap: wrap;">
                <span class="badge badge-gray">Chapters ${room.chapterStart} &ndash; ${room.chapterEnd}</span>

                <c:choose>
                    <c:when test="${sessionScope.currentUser != null}">
                        <c:choose>
                            <c:when test="${isSafe}">
                                <span class="badge badge-sage" title="You have read through Chapter ${userCh}">
                                    ✓ Spoiler Safe (You read Ch. ${userCh})
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-amber" title="Covers up to Chapter ${room.chapterEnd}, you're on Chapter ${userCh}">
                                    🔒 Gated (You're on Ch. ${userCh})
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <span class="badge badge-amber">🔒 Spoiler Protected</span>
                    </c:otherwise>
                </c:choose>
            </div>

            <h2 class="discussion-card-title">
                <a href="${pageContext.request.contextPath}/room?id=${room.id}">${room.title}</a>
            </h2>

            <p class="discussion-card-desc">${room.description}</p>

            <div class="discussion-card-meta">
                <span style="display: flex; align-items: center; gap: 6px; color: var(--text-muted);">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                    </svg>
                    ${room.postCount} ${room.postCount == 1 ? 'discussion topic' : 'discussion topics'}
                </span>

                <a href="${pageContext.request.contextPath}/room?id=${room.id}" class="btn btn-secondary btn-sm">
                    Enter Room &rarr;
                </a>
            </div>
        </article>
    </c:forEach>
</div>

<!-- Empty State -->
<c:if test="${empty rooms}">
    <div class="empty-state">
        <div class="empty-state-icon">☕</div>
        <h3 class="empty-state-title">No discussion rooms found</h3>
        <p class="empty-state-desc">
            No rooms have been scheduled for this title yet. Discussion rooms are opened chapter-by-chapter as readers progress through the story.
        </p>
        <a href="${pageContext.request.contextPath}/community" class="btn btn-primary">View All Rooms</a>
    </div>
</c:if>

<jsp:include page="includes/footer.jsp" />
