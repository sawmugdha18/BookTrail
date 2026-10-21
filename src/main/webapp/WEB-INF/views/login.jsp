<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Sign In to BookTrail" />
<c:set var="activePage" value="login" />
<jsp:include page="includes/header.jsp" />

<div class="auth-wrapper">
    <div class="auth-card">
        <div class="auth-header">
            <div class="brand-icon-box" style="margin: 0 auto 16px; width: 44px; height: 44px;">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1-2.5-2.5Z"></path>
                    <path d="m8 14 3-4 2 2.5 3-4 3 4.5"></path>
                </svg>
            </div>
            <h1>Welcome Back</h1>
            <p class="page-subtitle" style="margin: 0 auto;">Sign in to your reading log and discussions</p>
        </div>

        <form action="${pageContext.request.contextPath}/login" method="POST">
            <input type="hidden" name="redirect" value="${param.redirect}" />

            <div class="form-group">
                <label class="form-label" for="username">Username</label>
                <input type="text" id="username" name="username" class="form-control"
                       value="${username != null ? username : ''}" required autofocus
                       placeholder="Enter your reader username" />
            </div>

            <div class="form-group">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                    <label class="form-label" for="loginPassword" style="margin: 0;">Password</label>
                </div>
                <div class="password-input-wrap">
                    <input type="password" id="loginPassword" name="password" class="form-control"
                           required placeholder="••••••••" />
                    <button type="button" class="password-toggle-btn" data-target="loginPassword" aria-label="Toggle password visibility">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                            <circle cx="12" cy="12" r="3"></circle>
                        </svg>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn btn-primary btn-lg" style="width: 100%; margin-top: 10px;">
                Sign In to Reading Log
            </button>
        </form>

        <div class="demo-account-hint">
            <strong>Demo Accounts (password: <code>password123</code>):</strong>
            <ul style="margin: 6px 0 0 18px; color: var(--text-secondary); line-height: 1.6;">
                <li><code>elena_reader</code> &mdash; Reader tracking Dune &amp; The Hobbit</li>
                <li><code>admin</code> &mdash; Full administrator console access</li>
            </ul>
        </div>

        <div class="auth-footer">
            New to the café? <a href="${pageContext.request.contextPath}/register">Create a free reading log</a>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
