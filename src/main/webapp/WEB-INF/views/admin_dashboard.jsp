<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MavenGuard - Admin Dashboard</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">

  <style>
    /* --- Design System (index.jsp와 통일) --- */
    :root {
      --bg-body: #f8fafc;
      --surface-color: #ffffff;
      --primary-dark: #0f172a;
      --primary-accent: #3b82f6;
      --danger-color: #ef4444;
      --text-main: #334155;
      --text-sub: #64748b;
      --border-color: #e2e8f0;
      --font-ui: 'Inter', sans-serif;
      --font-code: 'JetBrains Mono', monospace;
      --shadow-soft: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
    }

    body {
      background-color: var(--bg-body);
      color: var(--text-main);
      font-family: var(--font-ui);
      -webkit-font-smoothing: antialiased;
    }

    /* Navbar */
    .navbar {
      background: rgba(255, 255, 255, 0.95);
      backdrop-filter: blur(10px);
      border-bottom: 1px solid var(--border-color);
      padding: 1rem 0;
    }
    .brand-logo {
      font-family: var(--font-code);
      font-weight: 700;
      font-size: 1.35rem;
      color: var(--primary-dark);
      letter-spacing: -0.03em;
      display: flex;
      align-items: center;
      gap: 10px;
      text-decoration: none;
    }

    /* Main Card */
    .main-card {
      background: var(--surface-color);
      border: 1px solid var(--border-color);
      border-radius: 20px;
      box-shadow: var(--shadow-soft);
      overflow: hidden;
      padding: 2rem;
    }

    /* Table Styling */
    .table-custom {
      margin-bottom: 0;
    }
    .table-custom th {
      background-color: #f8fafc;
      color: var(--text-sub);
      font-weight: 600;
      text-transform: uppercase;
      font-size: 0.85rem;
      letter-spacing: 0.05em;
      padding: 1rem;
      border-bottom: 2px solid var(--border-color);
    }
    .table-custom td {
      padding: 1rem;
      vertical-align: middle;
      border-bottom: 1px solid #f1f5f9;
      color: var(--text-main);
      font-size: 0.95rem;
    }
    .table-custom tr:last-child td {
      border-bottom: none;
    }

    /* Badges */
    .role-badge {
      font-family: var(--font-code);
      font-size: 0.8rem;
      padding: 5px 10px;
      border-radius: 6px;
      font-weight: 600;
    }
    .role-admin {
      background-color: #fef2f2;
      color: var(--danger-color);
      border: 1px solid #fecaca;
    }
    .role-user {
      background-color: #eff6ff;
      color: var(--primary-accent);
      border: 1px solid #bfdbfe;
    }
  </style>
</head>
<body>

<nav class="navbar sticky-top">
  <div class="container">
    <a class="brand-logo" href="${pageContext.request.contextPath}/">
            <span class="fa-stack" style="font-size: 0.8em;">
              <i class="fas fa-circle fa-stack-2x" style="color: rgba(239, 68, 68, 0.1);"></i>
              <i class="fas fa-user-shield fa-stack-1x text-danger"></i>
            </span>
      MavenGuard
      <span class="badge bg-danger ms-2 rounded-pill" style="font-size: 0.6em; vertical-align: middle;">ADMIN</span>
    </a>

    <a href="${pageContext.request.contextPath}/" class="btn btn-outline-secondary rounded-pill px-4 fw-medium text-sm">
      <i class="fas fa-arrow-right-from-bracket me-2"></i>Exit Admin
    </a>
  </div>
</nav>

<div class="container py-5">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <div>
      <h3 class="fw-bold mb-1" style="color: var(--primary-dark);">Dashboard</h3>
      <p class="text-secondary mb-0">전체 회원 및 권한 관리</p>
    </div>
    <div class="bg-white px-3 py-2 rounded-pill border shadow-sm text-secondary small fw-bold">
      <i class="fas fa-users me-2 text-primary"></i>Total Users: ${users.size()}
    </div>
  </div>

  <div class="main-card">
    <div class="table-responsive">
      <table class="table table-custom table-hover">
        <thead>
        <tr>
          <th style="width: 10%;">ID</th>
          <th style="width: 30%;">Email</th>
          <th style="width: 25%;">Nickname</th>
          <th style="width: 15%;">Role</th>
          <th style="width: 20%;">Joined Date</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="u" items="${users}">
          <tr>
            <td class="font-code text-secondary">#${u.userId}</td>
            <td class="fw-medium">${u.email}</td>
            <td>
              <div class="d-flex align-items-center gap-2">
                <div class="bg-light rounded-circle d-flex align-items-center justify-content-center" style="width: 32px; height: 32px;">
                  <i class="fas fa-user text-secondary opacity-50"></i>
                </div>
                  ${u.nickname}
              </div>
            </td>
            <td>
                            <span class="role-badge ${u.role == 'ROLE_ADMIN' ? 'role-admin' : 'role-user'}">
                                ${u.role}
                            </span>
            </td>
            <td class="text-secondary">
              <i class="far fa-calendar me-1"></i>
              <fmt:formatDate value="${u.createdAt}" pattern="yyyy.MM.dd HH:mm"/>
            </td>
          </tr>
        </c:forEach>

        <c:if test="${empty users}">
          <tr>
            <td colspan="5" class="text-center py-5 text-muted">
              <i class="fas fa-users-slash fa-2x mb-3 opacity-25"></i>
              <p>가입된 회원이 없습니다.</p>
            </td>
          </tr>
        </c:if>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>