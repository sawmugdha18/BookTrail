<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="My Bookshelf" />
<c:set var="activePage" value="shelf" />
<jsp:include page="includes/header.jsp" />

<div class="page-header" style="margin-top: 24px;">
    <h1 class="page-title">Personal Bookshelf</h1>
    <p class="page-subtitle">
        Track your chapter-by-chapter reading journey, adjust your reading pace, and unlock spoiler-safe discussion rooms.
    </p>
</div>

<!-- Reading Metrics Overview -->
<div class="shelf-metrics-grid">
    <div class="metric-card">
        <span class="metric-label">Currently Reading</span>
        <div class="metric-value" style="color: var(--accent-terracotta);">${readingCount}</div>
    </div>
    <div class="metric-card">
        <span class="metric-label">Books Completed</span>
        <div class="metric-value">${completedCount}</div>
    </div>
    <div class="metric-card">
        <span class="metric-label">Total Chapters Read</span>
        <div class="metric-value">${totalChaptersRead}</div>
    </div>
    <div class="metric-card">
        <span class="metric-label">Want to Read</span>
        <div class="metric-value" style="color: var(--text-secondary);">${wantCount}</div>
    </div>
</div>

<!-- Status Filter Tabs -->
<nav class="shelf-tabs-nav" aria-label="Bookshelf Filter Tabs">
    <a href="${pageContext.request.contextPath}/shelf?status=ALL" class="shelf-tab-link ${currentStatus == 'ALL' ? 'active' : ''}">
        All Books (${shelfItems.size()})
    </a>
    <a href="${pageContext.request.contextPath}/shelf?status=CURRENTLY_READING" class="shelf-tab-link ${currentStatus == 'CURRENTLY_READING' ? 'active' : ''}">
        Currently Reading (${readingCount})
    </a>
    <a href="${pageContext.request.contextPath}/shelf?status=COMPLETED" class="shelf-tab-link ${currentStatus == 'COMPLETED' ? 'active' : ''}">
        Completed (${completedCount})
    </a>
    <a href="${pageContext.request.contextPath}/shelf?status=WANT_TO_READ" class="shelf-tab-link ${currentStatus == 'WANT_TO_READ' ? 'active' : ''}">
        Want to Read (${wantCount})
    </a>
</nav>

<!-- Shelf Items List -->
<div class="shelf-items-list">
    <c:forEach var="item" items="${shelfItems}">
        <article class="shelf-item-card">
            <a href="${pageContext.request.contextPath}/book?id=${item.bookId}" class="shelf-item-cover" title="Open ${item.book.title}">
                <img src="${item.book.coverUrl}" alt="${item.book.title}"
                     onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&auto=format&fit=crop&q=80'" />
            </a>

            <div class="shelf-item-info">
                <div class="shelf-item-header">
                    <div>
                        <h2 style="font-size: 1.4rem; margin-bottom: 2px;">
                            <a href="${pageContext.request.contextPath}/book?id=${item.bookId}">${item.book.title}</a>
                        </h2>
                        <div style="color: var(--text-secondary); font-size: 0.9rem;">
                            by ${item.book.author} &bull; <span style="color: var(--accent-terracotta);">${item.book.genre}</span>
                        </div>
                    </div>

                    <span class="badge ${item.status == 'COMPLETED' ? 'badge-sage' : (item.status == 'CURRENTLY_READING' ? 'badge-amber' : 'badge-gray')}">
                        <c:choose>
                            <c:when test="${item.status == 'COMPLETED'}">✓ Completed</c:when>
                            <c:when test="${item.status == 'CURRENTLY_READING'}">Reading</c:when>
                            <c:otherwise>Want to Read</c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <!-- Progress Track -->
                <div class="shelf-progress-box">
                    <div style="display: flex; justify-content: space-between; font-size: 0.88rem; margin-bottom: 6px;">
                        <span>Chapter <strong>${item.chaptersRead}</strong> of ${item.book.totalChapters}</span>
                        <span id="percentLabel_${item.bookId}"><strong>${item.progressPercentage}%</strong> completed</span>
                    </div>
                    <div class="progress-track">
                        <div id="fill_${item.bookId}" class="progress-bar-fill" style="width: ${item.progressPercentage}%;"></div>
                    </div>
                </div>

                <c:if test="${not empty item.notes}">
                    <div style="font-size: 0.88rem; color: var(--text-secondary); font-style: italic; background-color: var(--secondary-sage-subtle); padding: 10px 14px; border-radius: var(--radius-sm); border-left: 3px solid var(--secondary-sage);">
                        &ldquo;<c:out value="${item.notes}" />&rdquo;
                    </div>
                </c:if>

                <!-- Quick Inline Controls -->
                <div class="shelf-controls-row">
                    <!-- Progress Update Form -->
                    <form action="${pageContext.request.contextPath}/shelf/update" method="POST" style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                        <input type="hidden" name="bookId" value="${item.bookId}" />
                        <label for="ch_${item.bookId}" style="font-size: 0.85rem; color: var(--text-secondary); white-space: nowrap;">I am on Chapter:</label>
                        <input type="number" id="ch_${item.bookId}" name="chaptersRead"
                               min="0" max="${item.book.totalChapters}" value="${item.chaptersRead}"
                               class="form-control input-chapter-sync"
                               style="width: 80px; padding: 6px 10px; font-size: 0.88rem;"
                               data-total="${item.book.totalChapters}"
                               data-fill-id="fill_${item.bookId}"
                               data-label-id="percentLabel_${item.bookId}" />

                        <select name="status" class="form-control" style="padding: 6px 10px; font-size: 0.88rem; width: auto;">
                            <option value="CURRENTLY_READING" ${item.status == 'CURRENTLY_READING' ? 'selected' : ''}>Reading</option>
                            <option value="COMPLETED" ${item.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                            <option value="WANT_TO_READ" ${item.status == 'WANT_TO_READ' ? 'selected' : ''}>Want to Read</option>
                        </select>

                        <button type="submit" class="btn btn-primary btn-sm">Update</button>
                    </form>

                    <!-- Book Detail & Discussion Rooms Links -->
                    <div style="display: flex; gap: 8px; align-items: center;">
                        <a href="${pageContext.request.contextPath}/community?bookId=${item.bookId}" class="btn btn-secondary btn-sm" title="Spoiler-safe rooms for this book">
                            Chapter Rooms 💬
                        </a>
                        <form action="${pageContext.request.contextPath}/shelf/remove" method="POST" onsubmit="return confirm('Remove ${item.book.title} from your shelf?');">
                            <input type="hidden" name="bookId" value="${item.bookId}" />
                            <button type="submit" class="btn btn-subtle btn-sm" title="Remove from shelf" style="color: #A33A3A;">
                                Remove
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </article>
    </c:forEach>
</div>

<!-- Empty State -->
<c:if test="${empty shelfItems}">
    <div class="empty-state">
        <div class="empty-state-icon">📚</div>
        <h3 class="empty-state-title">Your bookshelf is quiet</h3>
        <p class="empty-state-desc">
            <c:choose>
                <c:when test="${currentStatus != 'ALL'}">
                    You don't have any books listed under <strong>${currentStatus}</strong>.
                </c:when>
                <c:otherwise>
                    You haven't added any books to your personal shelf yet. Explore our mountain café shelves and pick your next story.
                </c:otherwise>
            </c:choose>
        </p>
        <a href="${pageContext.request.contextPath}/discover" class="btn btn-primary">Browse Curated Shelves</a>
    </div>
</c:if>

<jsp:include page="includes/footer.jsp" />
