<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Caretaker &amp; Admin Console" />
<c:set var="activePage" value="admin" />
<jsp:include page="includes/header.jsp" />

<div class="page-header" style="margin-top: 24px;">
    <h1 class="page-title">Café Caretaker &amp; Admin Console</h1>
    <p class="page-subtitle">Manage books, configure chapter discussion rooms, and oversee platform activity.</p>
</div>

<!-- System Status Indicator Card -->
<div class="card" style="margin-bottom: 32px; border-left: 4px solid var(--primary-forest);">
    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
        <div style="display: flex; align-items: center; gap: 10px;">
            <strong style="color: var(--text-primary);">Database Engine:</strong>
            <c:choose>
                <c:when test="${isMySql}">
                    <span class="badge badge-sage">MySQL Connected (Port 3306)</span>
                </c:when>
                <c:otherwise>
                    <span class="badge badge-amber">Embedded Fallback (MySQL Mode)</span>
                </c:otherwise>
            </c:choose>
        </div>

        <div style="font-size: 0.9rem; color: var(--text-secondary);">
            Users: <strong>${users.size()}</strong> &bull;
            Books: <strong>${books.size()}</strong> &bull;
            Chapter Rooms: <strong>${rooms.size()}</strong>
        </div>
    </div>
</div>

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 32px; margin-bottom: 36px;">
    <!-- Add Book Form -->
    <section class="card" aria-labelledby="add-book-heading">
        <h2 id="add-book-heading" style="font-size: 1.35rem; margin-bottom: 16px;">Add New Book to Shelves</h2>
        <form action="${pageContext.request.contextPath}/admin/book/add" method="POST">
            <div class="form-group">
                <label class="form-label" for="bTitle">Book Title</label>
                <input type="text" id="bTitle" name="title" class="form-control" required placeholder="e.g. The Left Hand of Darkness" />
            </div>

            <div class="form-group">
                <label class="form-label" for="bAuthor">Author</label>
                <input type="text" id="bAuthor" name="author" class="form-control" required placeholder="e.g. Ursula K. Le Guin" />
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                <div class="form-group">
                    <label class="form-label" for="bGenre">Genre</label>
                    <input type="text" id="bGenre" name="genre" class="form-control" required placeholder="e.g. Science Fiction" />
                </div>
                <div class="form-group">
                    <label class="form-label" for="bChapters">Total Chapters</label>
                    <input type="number" id="bChapters" name="totalChapters" min="1" class="form-control" required placeholder="e.g. 20" />
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                <div class="form-group">
                    <label class="form-label" for="bYear">Published Year</label>
                    <input type="number" id="bYear" name="publishedYear" class="form-control" required placeholder="e.g. 1969" />
                </div>
                <div class="form-group">
                    <label class="form-label" for="bCover">Cover Image URL</label>
                    <input type="url" id="bCover" name="coverUrl" class="form-control" placeholder="https://..." />
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="bSynopsis">Synopsis</label>
                <textarea id="bSynopsis" name="synopsis" class="form-control" rows="3" required placeholder="A brief atmospheric summary of the book..."></textarea>
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%;">Add Book to Shelves</button>
        </form>
    </section>

    <!-- Add Discussion Room Form -->
    <section class="card" aria-labelledby="add-room-heading">
        <h2 id="add-room-heading" style="font-size: 1.35rem; margin-bottom: 16px;">Create Chapter Discussion Room</h2>
        <form action="${pageContext.request.contextPath}/admin/room/add" method="POST">
            <div class="form-group">
                <label class="form-label" for="rBook">Select Book</label>
                <select id="rBook" name="bookId" class="form-control" required>
                    <c:forEach var="b" items="${books}">
                        <option value="${b.id}">${b.title} (${b.totalChapters} Ch.)</option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label" for="rTitle">Room Title</label>
                <input type="text" id="rTitle" name="title" class="form-control" required placeholder="e.g. Karhide &amp; The Ice Crossing (Ch. 1-8)" />
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                <div class="form-group">
                    <label class="form-label" for="rStart">Chapter Start</label>
                    <input type="number" id="rStart" name="chapterStart" min="1" class="form-control" required value="1" />
                </div>
                <div class="form-group">
                    <label class="form-label" for="rEnd">Chapter End (Spoiler Barrier)</label>
                    <input type="number" id="rEnd" name="chapterEnd" min="1" class="form-control" required value="8" />
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="rDesc">Description / Reading Focus</label>
                <textarea id="rDesc" name="description" class="form-control" rows="3" placeholder="What themes, characters, or questions should readers reflect on?"></textarea>
            </div>

            <button type="submit" class="btn btn-terracotta" style="width: 100%;">Create Discussion Room</button>
        </form>
    </section>
</div>

<!-- Books Catalog Management Table -->
<section class="card" style="margin-bottom: 32px;" aria-labelledby="catalog-heading">
    <h2 id="catalog-heading" style="font-size: 1.35rem; margin-bottom: 16px;">Catalog Books (${books.size()})</h2>
    <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse; font-size: 0.9rem;">
            <thead>
                <tr style="border-bottom: 2px solid var(--border-color); text-align: left; color: var(--text-secondary);">
                    <th style="padding: 12px;">ID</th>
                    <th style="padding: 12px;">Title</th>
                    <th style="padding: 12px;">Author</th>
                    <th style="padding: 12px;">Genre</th>
                    <th style="padding: 12px;">Chapters</th>
                    <th style="padding: 12px;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="b" items="${books}">
                    <tr style="border-bottom: 1px solid var(--border-subtle);">
                        <td style="padding: 12px; color: var(--text-muted);">${b.id}</td>
                        <td style="padding: 12px; font-weight: 600;">
                            <a href="${pageContext.request.contextPath}/book?id=${b.id}" style="color: var(--text-primary);">${b.title}</a>
                        </td>
                        <td style="padding: 12px;">${b.author}</td>
                        <td style="padding: 12px;"><span class="badge badge-gray">${b.genre}</span></td>
                        <td style="padding: 12px;">${b.totalChapters}</td>
                        <td style="padding: 12px;">
                            <form action="${pageContext.request.contextPath}/admin/book/delete" method="POST" onsubmit="return confirm('Delete this book and all its discussion rooms?');" style="display: inline;">
                                <input type="hidden" name="bookId" value="${b.id}" />
                                <button type="submit" class="btn btn-subtle btn-sm" style="color: #A33A3A; padding: 4px 10px;">Delete</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</section>

<!-- Registered Users Table -->
<section class="card" style="margin-bottom: 48px;" aria-labelledby="users-heading">
    <h2 id="users-heading" style="font-size: 1.35rem; margin-bottom: 16px;">Registered Café Members (${users.size()})</h2>
    <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse; font-size: 0.9rem;">
            <thead>
                <tr style="border-bottom: 2px solid var(--border-color); text-align: left; color: var(--text-secondary);">
                    <th style="padding: 12px;">ID</th>
                    <th style="padding: 12px;">Reader</th>
                    <th style="padding: 12px;">Email</th>
                    <th style="padding: 12px;">Role</th>
                    <th style="padding: 12px;">Joined</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="u" items="${users}">
                    <tr style="border-bottom: 1px solid var(--border-subtle);">
                        <td style="padding: 12px; color: var(--text-muted);">${u.id}</td>
                        <td style="padding: 12px; font-weight: 600;">${u.username}</td>
                        <td style="padding: 12px; color: var(--text-secondary);">${u.email}</td>
                        <td style="padding: 12px;">
                            <span class="badge ${u.admin ? 'badge-amber' : 'badge-sage'}">${u.role}</span>
                        </td>
                        <td style="padding: 12px; color: var(--text-muted);">${u.createdAt}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</section>

<jsp:include page="includes/footer.jsp" />
