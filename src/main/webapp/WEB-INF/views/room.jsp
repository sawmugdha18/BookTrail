<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="${room.title} — BookTrail" />
<c:set var="activePage" value="community" />
<jsp:include page="includes/header.jsp" />

<!-- Breadcrumbs Navigation -->
<div style="margin-top: 20px; margin-bottom: 24px;">
    <a href="${pageContext.request.contextPath}/community?bookId=${room.bookId}" style="color: var(--text-muted); font-size: 0.9rem; display: inline-flex; align-items: center; gap: 6px;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="19" y1="12" x2="5" y2="12"></line>
            <polyline points="12 19 5 12 12 5"></polyline>
        </svg>
        Back to ${room.book.title} Rooms
    </a>
</div>

<!-- Discussion Room Header Banner -->
<div class="card" style="margin-bottom: 32px; border-left: 4px solid var(--accent-terracotta);">
    <div style="display: flex; gap: 20px; align-items: center; flex-wrap: wrap;">
        <a href="${pageContext.request.contextPath}/book?id=${room.bookId}" title="View book details">
            <img src="${room.book.coverUrl}" alt="${room.book.title}"
                 style="width: 64px; height: 96px; object-fit: cover; border-radius: var(--radius-sm); box-shadow: var(--shadow-sm);"
                 onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&auto=format&fit=crop&q=80'" />
        </a>

        <div style="flex: 1; min-width: 260px;">
            <div style="display: flex; gap: 8px; align-items: center; margin-bottom: 6px; flex-wrap: wrap;">
                <span class="badge badge-sage">Chapters ${room.chapterStart} &ndash; ${room.chapterEnd}</span>
                <span style="font-size: 0.88rem; color: var(--text-secondary);">
                    from <a href="${pageContext.request.contextPath}/book?id=${room.bookId}" style="color: var(--accent-terracotta); font-weight: 600;">${room.book.title}</a> by ${room.book.author}
                </span>
            </div>
            <h1 style="font-size: clamp(1.6rem, 2.8vw, 2.1rem); margin-bottom: 6px;">${room.title}</h1>
            <p style="color: var(--text-secondary); font-size: 0.95rem; margin: 0;">${room.description}</p>
        </div>
    </div>
</div>

<c:choose>
    <%-- =======================================================================
         SERVER-SIDE SPOILER ACCESS GATE
         ======================================================================= --%>
    <c:when test="${isSpoilerBlocked}">
        <section class="spoiler-gate-card" aria-label="Spoiler Protection Barrier">
            <div class="spoiler-shield-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                </svg>
            </div>

            <h2 class="spoiler-gate-title">Spoiler Barrier Active</h2>

            <p class="spoiler-gate-msg">
                This discussion room explores revelations up to <strong>Chapter ${room.chapterEnd}</strong> of
                <em>${room.book.title}</em>.<br/>
                <c:choose>
                    <c:when test="${sessionScope.currentUser != null}">
                        Your reading log currently records you at <strong>Chapter ${userChapters}</strong> of ${room.book.totalChapters}.
                        To preserve your suspense, all posts in this room remain gated on the server until you catch up.
                    </c:when>
                    <c:otherwise>
                        You are browsing as an anonymous guest. This room covers plot moments up to Chapter ${room.chapterEnd}.
                    </c:otherwise>
                </c:choose>
            </p>

            <div class="spoiler-gate-actions">
                <c:if test="${sessionScope.currentUser != null}">
                    <!-- One-click: Update shelf progress and enter -->
                    <form action="${pageContext.request.contextPath}/shelf/update" method="POST">
                        <input type="hidden" name="bookId" value="${room.bookId}" />
                        <input type="hidden" name="chaptersRead" value="${room.chapterEnd}" />
                        <input type="hidden" name="redirect" value="${pageContext.request.contextPath}/room?id=${room.id}&bypass=true" />
                        <button type="submit" class="btn btn-primary">
                            I've read through Chapter ${room.chapterEnd} &rarr; Update Log &amp; Enter
                        </button>
                    </form>
                </c:if>

                <!-- Explicit spoiler bypass -->
                <a href="${pageContext.request.contextPath}/room?id=${room.id}&bypass=true" class="btn btn-secondary">
                    I accept spoilers, proceed anyway
                </a>

                <a href="${pageContext.request.contextPath}/community?bookId=${room.bookId}" class="btn btn-subtle">
                    Return to Safe Rooms
                </a>
            </div>
        </section>
    </c:when>

    <%-- =======================================================================
         UNLOCKED POST FEED & THREADS
         ======================================================================= --%>
    <c:otherwise>
        <!-- Start a New Chapter Discussion Form -->
        <section class="card" style="margin-bottom: 36px;" aria-labelledby="new-topic-heading">
            <h2 id="new-topic-heading" style="font-size: 1.35rem; margin-bottom: 16px;">
                Start a New Discussion in Chapters ${room.chapterStart}&ndash;${room.chapterEnd}
            </h2>

            <c:choose>
                <c:when test="${sessionScope.currentUser != null}">
                    <form action="${pageContext.request.contextPath}/post/create" method="POST">
                        <input type="hidden" name="roomId" value="${room.id}" />

                        <div class="form-group">
                            <label class="form-label" for="topicTitle">Discussion Topic</label>
                            <input type="text" id="topicTitle" name="title" class="form-control" required
                                   placeholder="e.g. The character turning point in Chapter ${room.chapterStart}..." />
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="topicContent">Your Observations &amp; Reflections</label>
                            <textarea id="topicContent" name="content" class="form-control" rows="3" required
                                      placeholder="Share what caught your attention, symbolism, or questions for other readers..."></textarea>
                        </div>

                        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                            <label style="display: flex; align-items: center; gap: 8px; font-size: 0.88rem; color: var(--text-secondary); cursor: pointer;">
                                <input type="checkbox" name="hasSpoilers" />
                                <span>Tag as heavy chapter spoiler</span>
                            </label>

                            <button type="submit" class="btn btn-primary">Publish Discussion</button>
                        </div>
                    </form>
                </c:when>
                <c:otherwise>
                    <div style="padding: 16px; background-color: var(--surface-elevated); border: 1px dashed var(--border-color); border-radius: var(--radius-md); font-size: 0.92rem; color: var(--text-secondary);">
                        <a href="${pageContext.request.contextPath}/login?redirect=${pageContext.request.contextPath}/room?id=${room.id}%26bypass=true" style="color: var(--accent-terracotta); font-weight: 600;">Sign in</a> or
                        <a href="${pageContext.request.contextPath}/register" style="color: var(--accent-terracotta); font-weight: 600;">join BookTrail</a> to contribute to this chapter room.
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

        <!-- Discussions Stream -->
        <h2 style="font-size: 1.5rem; margin-bottom: 20px;">
            Chapter Conversations (${posts.size()})
        </h2>

        <div class="post-stream">
            <c:forEach var="post" items="${posts}">
                <article class="post-card" id="post-${post.id}">
                    <div class="post-header">
                        <div class="post-author-block">
                            <span class="user-avatar" style="width: 36px; height: 36px; font-size: 0.95rem;">
                                ${post.authorUsername.substring(0, 1).toUpperCase()}
                            </span>
                            <div>
                                <div style="font-weight: 600; font-size: 0.95rem;">${post.authorUsername}</div>
                                <div style="font-size: 0.8rem; color: var(--text-muted);">${post.createdAt}</div>
                            </div>
                        </div>

                        <div style="display: flex; gap: 8px; align-items: center;">
                            <c:if test="${post.hasSpoilers}">
                                <span class="badge badge-amber">Chapter Spoiler</span>
                            </c:if>
                            <c:if test="${sessionScope.currentUser != null && (sessionScope.currentUser.admin || sessionScope.currentUser.id == post.userId)}">
                                <form action="${pageContext.request.contextPath}/post/delete" method="POST" onsubmit="return confirm('Delete this post?');" style="margin: 0;">
                                    <input type="hidden" name="roomId" value="${room.id}" />
                                    <input type="hidden" name="postId" value="${post.id}" />
                                    <button type="submit" class="btn btn-subtle btn-sm" style="color: #A33A3A; padding: 2px 8px; font-size: 0.78rem;">
                                        Delete
                                    </button>
                                </form>
                            </c:if>
                        </div>
                    </div>

                    <h3 class="post-title"><c:out value="${post.title}" /></h3>
                    <div class="post-body"><c:out value="${post.content}" /></div>

                    <!-- Replies Thread -->
                    <div class="replies-thread">
                        <h4 style="font-size: 0.95rem; margin-bottom: 12px; color: var(--text-secondary);">
                            Responses (${post.comments.size()})
                        </h4>

                        <c:forEach var="comment" items="${post.comments}">
                            <div class="reply-item">
                                <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.84rem; margin-bottom: 4px;">
                                    <div>
                                        <span style="font-weight: 600;"><c:out value="${comment.authorUsername}" /></span>
                                        <span style="color: var(--text-muted); margin-left: 6px;">${comment.createdAt}</span>
                                    </div>
                                    <c:if test="${sessionScope.currentUser != null && (sessionScope.currentUser.admin || sessionScope.currentUser.id == comment.userId)}">
                                        <form action="${pageContext.request.contextPath}/comment/delete" method="POST" onsubmit="return confirm('Delete this reply?');" style="margin: 0;">
                                            <input type="hidden" name="roomId" value="${room.id}" />
                                            <input type="hidden" name="commentId" value="${comment.id}" />
                                            <button type="submit" class="btn btn-subtle btn-sm" style="color: #A33A3A; padding: 0 4px; font-size: 0.75rem; border: none; background: transparent; cursor: pointer;">
                                                &times; Delete
                                            </button>
                                        </form>
                                    </c:if>
                                </div>
                                <div style="font-size: 0.92rem; color: var(--text-primary); line-height: 1.55;">
                                    <c:out value="${comment.content}" />
                                </div>
                            </div>
                        </c:forEach>

                        <!-- Reply Submission Form -->
                        <c:choose>
                            <c:when test="${sessionScope.currentUser != null}">
                                <form action="${pageContext.request.contextPath}/comment/create" method="POST" style="margin-top: 14px;">
                                    <input type="hidden" name="roomId" value="${room.id}" />
                                    <input type="hidden" name="postId" value="${post.id}" />
                                    <div style="display: flex; gap: 8px;">
                                        <input type="text" name="content" class="form-control" required placeholder="Write a thoughtful reply..." style="padding: 8px 12px; font-size: 0.88rem;" />
                                        <button type="submit" class="btn btn-secondary btn-sm" style="flex-shrink: 0;">Reply</button>
                                    </div>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <div style="margin-top: 10px; font-size: 0.84rem; color: var(--text-muted);">
                                    <a href="${pageContext.request.contextPath}/login?redirect=${pageContext.request.contextPath}/room?id=${room.id}%26bypass=true" style="color: var(--accent-terracotta);">Sign in</a> to reply to this thread.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </article>
            </c:forEach>

            <c:if test="${empty posts}">
                <div class="empty-state">
                    <div class="empty-state-icon">💭</div>
                    <h3 class="empty-state-title">No conversations here yet</h3>
                    <p class="empty-state-desc">
                        Be the first reader to publish reflections on Chapters ${room.chapterStart}&ndash;${room.chapterEnd}.
                    </p>
                </div>
            </c:if>
        </div>
    </c:otherwise>
</c:choose>

<jsp:include page="includes/footer.jsp" />
