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
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">

  <style>
    /* 기존 스타일 유지 */
    :root { --bg-body: #f8fafc; --surface-color: #ffffff; --primary-dark: #0f172a; --primary-accent: #3b82f6; --danger-color: #ef4444; --text-main: #334155; --text-sub: #64748b; --border-color: #e2e8f0; --font-ui: 'Inter', sans-serif; --font-code: 'JetBrains Mono', monospace; --shadow-soft: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06); }
    body { background-color: var(--bg-body); color: var(--text-main); font-family: var(--font-ui); -webkit-font-smoothing: antialiased; }
    .navbar { background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(10px); border-bottom: 1px solid var(--border-color); padding: 1rem 0; }
    .brand-logo { font-family: var(--font-code); font-weight: 700; font-size: 1.35rem; color: var(--primary-dark); letter-spacing: -0.03em; display: flex; align-items: center; gap: 10px; text-decoration: none; }
    .main-card { background: var(--surface-color); border: 1px solid var(--border-color); border-radius: 20px; box-shadow: var(--shadow-soft); overflow: hidden; padding: 2rem; margin-bottom: 2rem; }
    .table-custom { margin-bottom: 0; }
    .table-custom th { background-color: #f8fafc; color: var(--text-sub); font-weight: 600; text-transform: uppercase; font-size: 0.85rem; letter-spacing: 0.05em; padding: 1rem; border-bottom: 2px solid var(--border-color); }
    .table-custom td { padding: 1rem; vertical-align: middle; border-bottom: 1px solid #f1f5f9; color: var(--text-main); font-size: 0.95rem; }
    .role-badge { font-family: var(--font-code); font-size: 0.8rem; padding: 5px 10px; border-radius: 6px; font-weight: 600; }
    .role-admin { background-color: #fef2f2; color: var(--danger-color); border: 1px solid #fecaca; }
    .role-user { background-color: #eff6ff; color: var(--primary-accent); border: 1px solid #bfdbfe; }
    .section-title { font-weight: 700; color: var(--primary-dark); margin-bottom: 0.5rem; display: flex; align-items: center; gap: 10px; }
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
      <h4 class="section-title"><i class="fas fa-users-gear text-primary"></i>User Management</h4>
      <p class="text-secondary mb-0 small">가입된 회원의 권한을 수정하거나 강제 탈퇴시킬 수 있습니다.</p>
    </div>
    <div class="bg-white px-3 py-2 rounded-pill border shadow-sm text-secondary small fw-bold">
      Total: ${users.size()}
    </div>
  </div>

  <div class="main-card">
    <div class="table-responsive">
      <table class="table table-custom table-hover">
        <thead>
        <tr>
          <th style="width: 10%;">ID</th>
          <th style="width: 25%;">User Info</th>
          <th style="width: 15%;">Role</th>
          <th style="width: 20%;">Joined Date</th>
          <th style="width: 30%;">Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="u" items="${users}">
          <tr>
            <td class="font-code text-secondary">#${u.userId}</td>
            <td>
              <div class="fw-bold text-dark">${u.nickname}</div>
              <div class="small text-muted">${u.email}</div>
            </td>
            <td>
                            <span class="role-badge ${u.role == 'ROLE_ADMIN' ? 'role-admin' : 'role-user'}">
                                ${u.role}
                            </span>
            </td>
            <td class="text-secondary">
              <fmt:formatDate value="${u.createdAt}" pattern="yyyy.MM.dd"/>
            </td>
            <td>
              <c:if test="${u.email ne 'admin@mavenguard.com'}"> <button class="btn btn-sm btn-outline-primary me-1" onclick="changeRole(${u.userId}, '${u.role}')">
                <i class="fas fa-user-tag"></i> Role
              </button>
                <button class="btn btn-sm btn-outline-danger" onclick="deleteUser(${u.userId})">
                  <i class="fas fa-ban"></i> Ban
                </button>
              </c:if>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

  <div class="d-flex justify-content-between align-items-center mb-4 mt-5">
    <div>
      <h4 class="section-title"><i class="fas fa-box-open text-success"></i>Kit Management</h4>
      <p class="text-secondary mb-0 small">사용자들이 생성한 Kit를 모니터링하고 관리합니다.</p>
    </div>
    <div class="bg-white px-3 py-2 rounded-pill border shadow-sm text-secondary small fw-bold">
      Total: ${kits.size()}
    </div>
  </div>

  <div class="main-card">
    <div class="table-responsive">
      <table class="table table-custom table-hover">
        <thead>
        <tr>
          <th style="width: 10%;">ID</th>
          <th style="width: 40%;">Kit Info</th>
          <th style="width: 20%;">Owner</th> <th style="width: 15%;">Created</th>
          <th style="width: 15%;">Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="kit" items="${kits}">
          <tr>
            <td class="font-code text-secondary">#${kit.kitId}</td>
            <td>
              <div class="fw-bold text-dark">${kit.title}</div>
              <div class="small text-muted text-truncate" style="max-width: 200px;">${kit.description}</div>
            </td>
            <td>
                            <span class="badge bg-light text-dark border">
                                <i class="fas fa-user me-1"></i>User #${kit.userId}
                            </span>
            </td>
            <td class="text-secondary">
              <fmt:formatDate value="${kit.createdAt}" pattern="yyyy.MM.dd"/>
            </td>
            <td>
              <button class="btn btn-sm btn-outline-danger" onclick="deleteKit(${kit.kitId})">
                <i class="fas fa-trash-can"></i> Delete
              </button>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${empty kits}">
          <tr><td colspan="5" class="text-center py-4 text-muted">등록된 Kit이 없습니다.</td></tr>
        </c:if>
        </tbody>
      </table>
    </div>
  </div>

</div>

<script>
  const contextPath = "${pageContext.request.contextPath}";

  // 회원 권한 변경
  function changeRole(userId, currentRole) {
    const newRole = (currentRole === 'ROLE_USER') ? 'ROLE_ADMIN' : 'ROLE_USER';
    if(!confirm("이 사용자의 권한을 " + newRole + "로 변경하시겠습니까?")) return;

    fetch(contextPath + '/admin/users/' + userId + '/role?role=' + newRole, { method: 'POST' })
            .then(res => res.text())
            .then(msg => {
              if(msg === 'OK') location.reload();
              else alert('오류 발생');
            });
  }

  // 회원 강제 탈퇴
  function deleteUser(userId) {
    if(!confirm("정말 이 회원을 강제 탈퇴시키겠습니까? (복구 불가)")) return;

    fetch(contextPath + '/admin/users/' + userId + '/delete', { method: 'POST' })
            .then(res => res.text())
            .then(msg => {
              if(msg === 'OK') location.reload();
              else alert('오류 발생');
            });
  }

  // Kit 삭제
  function deleteKit(kitId) {
    if(!confirm("이 Kit를 삭제하시겠습니까?")) return;

    fetch(contextPath + '/admin/kits/' + kitId + '/delete', { method: 'POST' })
            .then(res => res.text())
            .then(msg => {
              if(msg === 'OK') location.reload();
              else alert('오류 발생');
            });
  }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>