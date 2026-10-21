<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle != null ? pageTitle : 'BookTrail'} — Mountain Literary Café & Reading Community</title>
    
    <!-- Anti-FOUC Theme Script (applies persisted theme before rendering) -->
    <script>
        (function() {
            try {
                var saved = localStorage.getItem('booktrail_theme');
                if (saved) {
                    document.documentElement.setAttribute('data-theme', saved);
                } else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
                    document.documentElement.setAttribute('data-theme', 'dark');
                }
            } catch (e) {}
        })();
    </script>

    <!-- Google Fonts: Cormorant Garamond, DM Serif Display & DM Sans -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,600;0,700;1,400;1,600&family=DM+Sans:ital,wght@0,400;0,500;0,600;0,700;1,400&family=DM+Serif+Display:ital@0;1&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
</head>
<body>
    <header class="site-header">
        <div class="container">
            <nav class="navbar" aria-label="Main Navigation">
                <!-- Brand Logo -->
                <a href="${pageContext.request.contextPath}/discover" class="brand-logo" aria-label="BookTrail Home">
                    <div class="brand-icon-box">
                        <!-- Custom Mountain + Open Book SVG Mark -->
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1-2.5-2.5Z"></path>
                            <path d="m8 14 3-4 2 2.5 3-4 3 4.5"></path>
                        </svg>
                    </div>
                    <div class="brand-text-group">
                        <span class="brand-title">BookTrail</span>
                        <span class="brand-tagline">Mountain Literary Café</span>
                    </div>
                </a>

                <!-- Desktop Nav Links -->
                <ul class="nav-links">
                    <li>
                        <a href="${pageContext.request.contextPath}/discover" class="nav-link ${activePage == 'discover' ? 'active' : ''}">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10"></circle>
                                <polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"></polygon>
                            </svg>
                            Discover
                        </a>
                    </li>
                    <c:if test="${sessionScope.currentUser != null}">
                        <li>
                            <a href="${pageContext.request.contextPath}/shelf" class="nav-link ${activePage == 'shelf' ? 'active' : ''}">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1-2.5-2.5Z"></path>
                                    <path d="M6 6h10"></path>
                                    <path d="M6 10h10"></path>
                                </svg>
                                My Books
                            </a>
                        </li>
                    </c:if>
                    <li>
                        <a href="${pageContext.request.contextPath}/community" class="nav-link ${activePage == 'community' ? 'active' : ''}">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                            </svg>
                            Community
                        </a>
                    </li>
                    <c:if test="${sessionScope.currentUser != null && sessionScope.currentUser.admin}">
                        <li>
                            <a href="${pageContext.request.contextPath}/admin" class="nav-link ${activePage == 'admin' ? 'active' : ''}">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect>
                                    <line x1="8" y1="21" x2="16" y2="21"></line>
                                    <line x1="12" y1="17" x2="12" y2="21"></line>
                                </svg>
                                Admin
                            </a>
                        </li>
                    </c:if>
                </ul>

                <!-- Nav Actions: Theme Toggle & Authentication -->
                <div class="nav-actions">
                    <!-- Light / Dark Theme Switcher Button -->
                    <button type="button" class="theme-toggle-btn" aria-label="Toggle theme" title="Toggle theme">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
                        </svg>
                    </button>

                    <c:choose>
                        <c:when test="${sessionScope.currentUser != null}">
                            <a href="${pageContext.request.contextPath}/profile" class="user-badge" title="View Reader Profile">
                                <span class="user-avatar">${sessionScope.currentUser.username.substring(0, 1).toUpperCase()}</span>
                                <span>${sessionScope.currentUser.username}</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/logout" class="btn btn-subtle btn-sm" title="Sign out">Log out</a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-secondary btn-sm">Log in</a>
                            <a href="${pageContext.request.contextPath}/register" class="btn btn-terracotta btn-sm">Join the café</a>
                        </c:otherwise>
                    </c:choose>

                    <!-- Mobile Hamburger Menu Button -->
                    <button type="button" class="mobile-menu-btn" aria-label="Open mobile menu" aria-expanded="false">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="3" y1="12" x2="21" y2="12"></line>
                            <line x1="3" y1="6" x2="21" y2="6"></line>
                            <line x1="3" y1="18" x2="21" y2="18"></line>
                        </svg>
                    </button>
                </div>
            </nav>
        </div>

        <!-- Mobile Drawer Navigation -->
        <div class="mobile-drawer" id="mobileDrawer">
            <ul class="mobile-nav-links">
                <li><a href="${pageContext.request.contextPath}/discover" class="mobile-nav-link ${activePage == 'discover' ? 'active' : ''}">Discover</a></li>
                <c:if test="${sessionScope.currentUser != null}">
                    <li><a href="${pageContext.request.contextPath}/shelf" class="mobile-nav-link ${activePage == 'shelf' ? 'active' : ''}">My Bookshelf</a></li>
                    <li><a href="${pageContext.request.contextPath}/profile" class="mobile-nav-link ${activePage == 'profile' ? 'active' : ''}">My Profile</a></li>
                </c:if>
                <li><a href="${pageContext.request.contextPath}/community" class="mobile-nav-link ${activePage == 'community' ? 'active' : ''}">Community Rooms</a></li>
                <c:if test="${sessionScope.currentUser != null && sessionScope.currentUser.admin}">
                    <li><a href="${pageContext.request.contextPath}/admin" class="mobile-nav-link ${activePage == 'admin' ? 'active' : ''}">Admin Console</a></li>
                </c:if>
            </ul>
            <div style="display: flex; gap: 10px; padding-top: 10px; border-top: 1px solid var(--border-color);">
                <c:choose>
                    <c:when test="${sessionScope.currentUser != null}">
                        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm" style="width: 100%;">Log Out</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-secondary btn-sm" style="flex: 1;">Log in</a>
                        <a href="${pageContext.request.contextPath}/register" class="btn btn-terracotta btn-sm" style="flex: 1;">Join the café</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </header>

    <main class="main-content">
        <div class="container">
            <!-- Global Flash Feedback Alerts -->
            <c:if test="${not empty param.success || not empty successMessage}">
                <div class="alert-box">
                    <div class="alert alert-success">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="20 6 9 17 4 12"></polyline>
                        </svg>
                        <span>${not empty successMessage ? successMessage : param.success}</span>
                    </div>
                </div>
            </c:if>
            <c:if test="${not empty param.error || not empty errorMessage}">
                <div class="alert-box">
                    <div class="alert alert-error">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="12" r="10"></circle>
                            <line x1="12" y1="8" x2="12" y2="12"></line>
                            <line x1="12" y1="16" x2="12.01" y2="16"></line>
                        </svg>
                        <span>${not empty errorMessage ? errorMessage : param.error}</span>
                    </div>
                </div>
            </c:if>
            <c:if test="${not empty param.msg}">
                <div class="alert-box">
                    <div class="alert alert-warning">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="12" r="10"></circle>
                            <line x1="12" y1="16" x2="12" y2="12"></line>
                            <line x1="12" y1="8" x2="12.01" y2="8"></line>
                        </svg>
                        <span>${param.msg}</span>
                    </div>
                </div>
            </c:if>
