<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
        </div><!-- /.container -->
    </main><!-- /.main-content -->

    <footer class="site-footer">
        <div class="container">
            <div class="footer-top">
                <div class="footer-brand">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <div class="brand-icon-box" style="width: 32px; height: 32px;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1-2.5-2.5Z"></path>
                                <path d="m8 14 3-4 2 2.5 3-4 3 4.5"></path>
                            </svg>
                        </div>
                        <span class="brand-title" style="font-size: 1.4rem;">BookTrail</span>
                    </div>
                    <p>
                        A quiet mountain sanctuary where readers discover timeless books, log chapter-by-chapter journeys, and discuss stories without fear of spoilers.
                    </p>
                </div>

                <div>
                    <h3 class="footer-heading">The Café Library</h3>
                    <ul class="footer-links-list">
                        <li><a href="${pageContext.request.contextPath}/discover">Curated Shelves</a></li>
                        <li><a href="${pageContext.request.contextPath}/discover?genre=Science+Fiction">Science Fiction</a></li>
                        <li><a href="${pageContext.request.contextPath}/discover?genre=Fantasy">Fantasy &amp; Epics</a></li>
                        <li><a href="${pageContext.request.contextPath}/discover?genre=Classic+Literature">Classic Literature</a></li>
                    </ul>
                </div>

                <div>
                    <h3 class="footer-heading">Reading Community</h3>
                    <ul class="footer-links-list">
                        <li><a href="${pageContext.request.contextPath}/community">The Reading Table</a></li>
                        <li><a href="${pageContext.request.contextPath}/community">Spoiler-Gated Rooms</a></li>
                        <c:if test="${sessionScope.currentUser != null}">
                            <li><a href="${pageContext.request.contextPath}/shelf">Personal Bookshelf</a></li>
                            <li><a href="${pageContext.request.contextPath}/profile">Reader Journal</a></li>
                        </c:if>
                    </ul>
                </div>

                <div>
                    <h3 class="footer-heading">Architecture</h3>
                    <ul class="footer-links-list">
                        <li><span style="color: var(--text-muted);">Java Servlets &amp; JSP</span></li>
                        <li><span style="color: var(--text-muted);">JDBC &amp; Apache Tomcat 10</span></li>
                        <li><span style="color: var(--text-muted);">Server-Side Spoiler Gates</span></li>
                        <c:if test="${sessionScope.currentUser != null && sessionScope.currentUser.admin}">
                            <li><a href="${pageContext.request.contextPath}/admin" style="color: var(--accent-terracotta);">Admin Console</a></li>
                        </c:if>
                    </ul>
                </div>
            </div>

            <div class="footer-bottom">
                <div>
                    &copy; 2026 BookTrail Literary Café &amp; Reading Society. Crafted for readers who savor every page.
                </div>
                <div style="display: flex; gap: 16px;">
                    <span>Rainy Mountain Edition</span>
                    <span>&bull;</span>
                    <span>Zero External Social Trackers</span>
                </div>
            </div>
        </div>
    </footer>

    <!-- BookTrail Client Interaction Script -->
    <script src="${pageContext.request.contextPath}/static/js/main.js"></script>
</body>
</html>
