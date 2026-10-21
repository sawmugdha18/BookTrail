<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Create a Reading Log — BookTrail" />
<c:set var="activePage" value="register" />
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
            <h1>Join BookTrail</h1>
            <p class="page-subtitle" style="margin: 0 auto;">Track your reading journey &amp; join spoiler-safe discussions</p>
        </div>

        <form action="${pageContext.request.contextPath}/register" method="POST">
            <div class="form-group">
                <label class="form-label" for="regUsername">Username</label>
                <input type="text" id="regUsername" name="username" class="form-control"
                       value="${username != null ? username : ''}" required autofocus
                       placeholder="e.g. mountain_reader" minlength="3" />
            </div>

            <div class="form-group">
                <label class="form-label" for="regEmail">Email Address</label>
                <input type="email" id="regEmail" name="email" class="form-control"
                       value="${email != null ? email : ''}" required
                       placeholder="reader@booktrail.org" />
            </div>

            <div class="form-group">
                <label class="form-label" for="regPassword">Password (at least 6 characters)</label>
                <div class="password-input-wrap">
                    <input type="password" id="regPassword" name="password" class="form-control"
                           required placeholder="••••••••" minlength="6" />
                    <button type="button" class="password-toggle-btn" data-target="regPassword" aria-label="Toggle password visibility">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                            <circle cx="12" cy="12" r="3"></circle>
                        </svg>
                    </button>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="regConfirmPassword">Confirm Password</label>
                <div class="password-input-wrap">
                    <input type="password" id="regConfirmPassword" name="confirmPassword" class="form-control"
                           required placeholder="••••••••" minlength="6" />
                    <button type="button" class="password-toggle-btn" data-target="regConfirmPassword" aria-label="Toggle password visibility">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                            <circle cx="12" cy="12" r="3"></circle>
                        </svg>
                    </button>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="regBio">Reader Bio (Optional)</label>
                <textarea id="regBio" name="bio" class="form-control" rows="2"
                          placeholder="Favorite authors, quiet morning reading rituals...">${bio != null ? bio : ''}</textarea>
            </div>

            <button type="submit" class="btn btn-terracotta btn-lg" style="width: 100%; margin-top: 10px;">
                Create Reading Log
            </button>
        </form>

        <div class="auth-footer">
            Already registered? <a href="${pageContext.request.contextPath}/login">Sign in here</a>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
