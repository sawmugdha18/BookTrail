<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Discover Stories &amp; Mountain Shelves" />
<c:set var="activePage" value="discover" />
<jsp:include page="includes/header.jsp" />

<c:choose>
    <%-- =======================================================================
         HOMEPAGE / LANDING CAFÉ HERO (When not actively filtering)
         ======================================================================= --%>
    <c:when test="${empty currentQuery && (empty currentGenre || currentGenre == 'ALL')}">
        <section class="hero-section" aria-label="BookTrail Mountain Café">
            <img src="${pageContext.request.contextPath}/static/images/hero-cafe.jpg"
                 alt="Cozy mountain café interior during rain with an open book and coffee"
                 class="hero-bg-img" />
            <div class="hero-overlay"></div>
            <div class="hero-content">
                <div class="hero-badge">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
                    </svg>
                    A Mountain Café for Mindful Readers
                </div>
                <h1 class="hero-title">Find your next chapter.</h1>
                <p class="hero-copy">
                    Nestled in the misty pines, BookTrail is a peaceful sanctuary to discover books, log your chapter progress, and engage in thoughtful, spoiler-safe conversations.
                </p>
                <div class="hero-actions">
                    <a href="#shelves-anchor" class="hero-btn-primary">
                        Explore the shelves
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-left: 6px;">
                            <line x1="12" y1="5" x2="12" y2="19"></line>
                            <polyline points="19 12 12 19 5 12"></polyline>
                        </svg>
                    </a>
                    <a href="${pageContext.request.contextPath}/community" class="hero-btn-secondary">
                        Join the community &rarr;
                    </a>
                </div>
            </div>
        </section>

        <!-- 5.B Featured Books Showcase -->
        <section style="margin-bottom: 56px;" aria-labelledby="featured-heading">
            <div class="section-header">
                <div>
                    <span style="font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--accent-terracotta); font-weight: 600;">Fresh from the Library</span>
                    <h2 class="section-title" id="featured-heading">Featured on the Timber Tables</h2>
                    <p class="section-desc">Hand-picked literature currently sparking deep chapter discussions in our café rooms.</p>
                </div>
            </div>

            <div class="featured-carousel">
                <c:forEach var="book" items="${books}" begin="0" end="3">
                    <article class="featured-card">
                        <div class="featured-cover-wrap">
                            <img src="${book.coverUrl}" alt="${book.title}" class="featured-cover-img"
                                 onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&auto=format&fit=crop&q=80'" />
                            <span class="featured-genre-pill">${book.genre}</span>
                        </div>
                        <h3 style="font-family: var(--font-heading); font-size: 1.35rem; margin-bottom: 4px;">
                            <a href="${pageContext.request.contextPath}/book?id=${book.id}">${book.title}</a>
                        </h3>
                        <div style="font-size: 0.88rem; color: var(--text-secondary); margin-bottom: 10px;">
                            by ${book.author} &bull; ${book.publishedYear}
                        </div>
                        <p style="font-size: 0.88rem; color: var(--text-muted); line-height: 1.5; margin-bottom: 16px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                            ${book.synopsis}
                        </p>
                        <div style="margin-top: auto; display: flex; align-items: center; justify-content: space-between; padding-top: 12px; border-top: 1px solid var(--border-subtle);">
                            <span style="font-size: 0.84rem; color: #D48806; font-weight: 600;">
                                ★ <c:choose><c:when test="${book.averageRating > 0}">${book.averageRating}</c:when><c:otherwise>New</c:otherwise></c:choose>
                            </span>
                            <a href="${pageContext.request.contextPath}/book?id=${book.id}" class="btn btn-secondary btn-sm">
                                View Details &rarr;
                            </a>
                        </div>
                    </article>
                </c:forEach>
            </div>
        </section>
    </c:when>

    <%-- =======================================================================
         ACTIVE FILTER / SEARCH RECAP HEADER
         ======================================================================= --%>
    <c:otherwise>
        <div class="page-header" style="margin-top: 24px;">
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
                <a href="${pageContext.request.contextPath}/discover" style="color: var(--text-muted); font-size: 0.88rem;">&larr; Back to Mountain Home</a>
            </div>
            <h1 class="page-title">
                <c:choose>
                    <c:when test="${not empty currentQuery}">
                        Search results for &ldquo;${currentQuery}&rdquo;
                    </c:when>
                    <c:otherwise>
                        ${currentGenre} Bookshelf
                    </c:otherwise>
                </c:choose>
            </h1>
            <p class="page-subtitle">Showing ${books.size()} books in our curated collection.</p>
        </div>
    </c:otherwise>
</c:choose>

<!-- 5.C Discover by Mood or Genre (Tasteful Café Menu Board) -->
<section class="mood-board" aria-labelledby="genres-heading">
    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
        <div>
            <h3 id="genres-heading" style="font-size: 1.25rem;">Browse Shelves by Genre &amp; Mood</h3>
            <p style="font-size: 0.88rem; color: var(--text-muted); margin: 0;">Explore literature tailored to your morning state of mind.</p>
        </div>
        <c:if test="${currentGenre != 'ALL' || not empty currentQuery}">
            <a href="${pageContext.request.contextPath}/discover" class="btn btn-subtle btn-sm">Reset All Filters</a>
        </c:if>
    </div>

    <div class="mood-pills">
        <a href="${pageContext.request.contextPath}/discover?genre=ALL${not empty currentQuery ? '&q=' : ''}${currentQuery}${not empty currentSort ? '&sort=' : ''}${currentSort}"
           class="mood-pill ${currentGenre == 'ALL' ? 'active' : ''}">
            <span>☕</span>
            <span>All Genres</span>
        </a>
        <c:forEach var="g" items="${genres}">
            <a href="${pageContext.request.contextPath}/discover?genre=${g}${not empty currentQuery ? '&q=' : ''}${currentQuery}${not empty currentSort ? '&sort=' : ''}${currentSort}"
               class="mood-pill ${currentGenre == g ? 'active' : ''}">
                <c:choose>
                    <c:when test="${g == 'Science Fiction'}"><span>🚀</span></c:when>
                    <c:when test="${g == 'Fantasy'}"><span>⚔️</span></c:when>
                    <c:when test="${g == 'Classic Literature'}"><span>📜</span></c:when>
                    <c:when test="${g == 'Literary Fiction'}"><span>🍃</span></c:when>
                    <c:when test="${g == 'Dystopian'}"><span>👁️</span></c:when>
                    <c:otherwise><span>📖</span></c:otherwise>
                </c:choose>
                <span>${g}</span>
            </a>
        </c:forEach>
    </div>
</section>

<!-- Filter, Search, and Sort Bar -->
<div id="shelves-anchor" class="filter-bar">
    <div class="filter-row-top">
        <form action="${pageContext.request.contextPath}/discover" method="GET" class="search-box">
            <svg class="search-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="11" cy="11" r="8"></circle>
                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
            <input type="text" name="q" class="search-input" placeholder="Search by book title or author..." value="${currentQuery}" />
            <c:if test="${currentGenre != 'ALL'}">
                <input type="hidden" name="genre" value="${currentGenre}" />
            </c:if>
            <c:if test="${not empty currentSort}">
                <input type="hidden" name="sort" value="${currentSort}" />
            </c:if>
        </form>

        <!-- Sorting Selector -->
        <div style="display: flex; align-items: center; gap: 8px;">
            <label for="sortDropdown" style="font-size: 0.88rem; color: var(--text-muted); white-space: nowrap;">Sort by:</label>
            <select id="sortDropdown" class="sort-select" onchange="window.location.href='${pageContext.request.contextPath}/discover?sort=' + this.value + '${not empty currentQuery ? '&q=' : ''}${currentQuery}${currentGenre != 'ALL' ? '&genre=' : ''}${currentGenre}'">
                <option value="" ${empty currentSort ? 'selected' : ''}>Default Shelf Order</option>
                <option value="rating" ${currentSort == 'rating' ? 'selected' : ''}>Highest Reader Rating</option>
                <option value="chapters" ${currentSort == 'chapters' ? 'selected' : ''}>Most Chapters</option>
                <option value="title" ${currentSort == 'title' ? 'selected' : ''}>Title (A &rarr; Z)</option>
            </select>
        </div>
    </div>
</div>

<!-- Books Catalog Grid -->
<section aria-label="Book Catalog">
    <div class="book-grid">
        <c:forEach var="book" items="${books}">
            <article class="book-card">
                <div class="book-card-top">
                    <a href="${pageContext.request.contextPath}/book?id=${book.id}" class="book-cover-link" title="Open ${book.title}">
                        <img src="${book.coverUrl}" alt="${book.title}" class="book-cover-img"
                             onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&auto=format&fit=crop&q=80'" />
                    </a>
                </div>

                <div class="book-card-body">
                    <span class="book-genre-tag">${book.genre}</span>
                    <h2 class="book-card-title">
                        <a href="${pageContext.request.contextPath}/book?id=${book.id}">${book.title}</a>
                    </h2>
                    <div class="book-card-author">by ${book.author} &bull; ${book.publishedYear}</div>
                    <p class="book-card-synopsis">${book.synopsis}</p>

                    <div class="book-card-meta">
                        <div class="book-card-rating">
                            ★ <c:choose>
                                <c:when test="${book.averageRating > 0}">${book.averageRating}</c:when>
                                <c:otherwise>New</c:otherwise>
                            </c:choose>
                            <c:if test="${book.reviewCount > 0}">
                                <span style="font-weight: 400; color: var(--text-muted); margin-left: 2px;">(${book.reviewCount})</span>
                            </c:if>
                        </div>
                        <span>${book.totalChapters} Chapters</span>
                    </div>
                </div>

                <div class="book-card-footer">
                    <c:choose>
                        <c:when test="${sessionScope.currentUser != null}">
                            <c:choose>
                                <c:when test="${not empty book.userShelfStatus}">
                                    <span class="badge ${book.userShelfStatus == 'COMPLETED' ? 'badge-sage' : (book.userShelfStatus == 'CURRENTLY_READING' ? 'badge-amber' : 'badge-gray')}">
                                        <c:choose>
                                            <c:when test="${book.userShelfStatus == 'COMPLETED'}">✓ Completed</c:when>
                                            <c:when test="${book.userShelfStatus == 'CURRENTLY_READING'}">Ch. ${book.userChaptersRead} / ${book.totalChapters}</c:when>
                                            <c:otherwise>Want to Read</c:otherwise>
                                        </c:choose>
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <form action="${pageContext.request.contextPath}/shelf/add" method="POST" style="display: flex; gap: 6px;">
                                        <input type="hidden" name="bookId" value="${book.id}" />
                                        <input type="hidden" name="redirect" value="${pageContext.request.contextPath}/discover" />
                                        <select name="status" class="form-control" style="padding: 4px 8px; font-size: 0.8rem; height: auto;">
                                            <option value="WANT_TO_READ">+ Want to Read</option>
                                            <option value="CURRENTLY_READING">+ Reading</option>
                                            <option value="COMPLETED">+ Completed</option>
                                        </select>
                                        <button type="submit" class="btn btn-subtle btn-sm">Save</button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-subtle btn-sm">+ Add to Shelf</a>
                        </c:otherwise>
                    </c:choose>

                    <a href="${pageContext.request.contextPath}/book?id=${book.id}" class="btn btn-secondary btn-sm" title="Explore ${book.title} Discussions">
                        Book &amp; Rooms &rarr;
                    </a>
                </div>
            </article>
        </c:forEach>
    </div>
</section>

<!-- Empty State -->
<c:if test="${empty books}">
    <div class="empty-state">
        <div class="empty-state-icon">☕</div>
        <h3 class="empty-state-title">No books found matching this inquiry</h3>
        <p class="empty-state-desc">
            We couldn't find any titles matching your search keywords or genre filter. Try exploring our complete collection or clearing search terms.
        </p>
        <a href="${pageContext.request.contextPath}/discover" class="btn btn-primary">Reset to All Books</a>
    </div>
</c:if>

<c:if test="${empty currentQuery && (empty currentGenre || currentGenre == 'ALL')}">
    <!-- 5.D Reading Corner / The Communal Table -->
    <section class="reading-corner-section" aria-labelledby="corner-heading">
        <div class="reading-corner-banner">
            <img src="${pageContext.request.contextPath}/static/images/communal-table.jpg"
                 alt="Readers gathering around a large rustic oak table in a mountain library"
                 class="reading-corner-bg" />
            <div class="reading-corner-overlay"></div>
            <div class="reading-corner-banner-content">
                <span class="hero-badge" style="margin-bottom: 12px;">The Communal Table</span>
                <h2 id="corner-heading">Live Chapter Discussions</h2>
                <p>Join readers gathered around our digital timber table. Every room is partitioned by chapter milestones so your reading experience remains pure and unhurried.</p>
            </div>
        </div>

        <div class="discussions-preview-grid">
            <c:forEach var="room" items="${featuredRooms}" begin="0" end="2">
                <article class="discussion-card">
                    <div class="discussion-book-tag">
                        <span>📖</span>
                        <strong>${room.book.title}</strong>
                        <span>&bull;</span>
                        <span>Ch. ${room.chapterStart}&ndash;${room.chapterEnd}</span>
                    </div>

                    <h3 class="discussion-card-title">
                        <a href="${pageContext.request.contextPath}/room?id=${room.id}">${room.title}</a>
                    </h3>

                    <p class="discussion-card-desc">${room.description}</p>

                    <div class="discussion-card-meta">
                        <span style="display: flex; align-items: center; gap: 6px; color: var(--text-muted);">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                            </svg>
                            ${room.postCount} ${room.postCount == 1 ? 'discussion' : 'discussions'}
                        </span>
                        <a href="${pageContext.request.contextPath}/room?id=${room.id}" class="btn btn-secondary btn-sm">
                            Enter Room &rarr;
                        </a>
                    </div>
                </article>
            </c:forEach>
        </div>
    </section>

    <!-- 5.E Community Invitation & Server-Side Spoiler Protection Philosophy -->
    <section class="invitation-banner" aria-labelledby="invitation-heading">
        <div class="invitation-left">
            <span style="font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--accent-terracotta); font-weight: 600;">The Reading Pledge</span>
            <h2 id="invitation-heading">Read at your own pace. Never fear spoilers.</h2>
            <p>
                In standard online book clubs, scrolling a discussion board often ruins major plot twists. At BookTrail, our server checks your reading progress before revealing post contents.
            </p>
            <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                <c:choose>
                    <c:when test="${sessionScope.currentUser != null}">
                        <a href="${pageContext.request.contextPath}/shelf" class="btn btn-primary">Manage Your Bookshelf</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">Create Your Free Log</a>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-secondary">Sign In</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="invitation-features">
            <div class="feature-point">
                <div class="feature-icon-badge">🛡️</div>
                <div>
                    <h4>Server-Enforced Spoiler Barriers</h4>
                    <p>Rooms are partitioned by chapters. Posts remain securely gated on the server until your log indicates you have read through that chapter milestone.</p>
                </div>
            </div>

            <div class="feature-point">
                <div class="feature-icon-badge">📑</div>
                <div>
                    <h4>Chapter-by-Chapter Tracking</h4>
                    <p>Log the exact chapter you finished over your morning brew. Update in one click from your personal bookshelf.</p>
                </div>
            </div>

            <div class="feature-point">
                <div class="feature-icon-badge">☕</div>
                <div>
                    <h4>Quiet, Focused Aesthetic</h4>
                    <p>No noisy algorithms, no clickbait feeds. Just pure books, genuine reflections, and a calm mountain atmosphere.</p>
                </div>
            </div>
        </div>
    </section>
</c:if>

<jsp:include page="includes/footer.jsp" />
