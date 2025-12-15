<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <title>Admin Dashboard</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark bg-danger">
  <div class="container">
    <span class="navbar-brand mb-0 h1">MavenGuard ADMIN</span>
    <a href="/index.jsp" class="btn btn-sm btn-light">메인으로</a>
  </div>
</nav>
<div class="container py-4">
  <h4>회원 관리</h4>
  <table class="table table-bordered bg-white">
    <thead>
    <tr>
      <th>ID</th><th>Email</th><th>Nickname</th><th>Role</th><th>가입일</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach var="u" items="${users}">
      <tr>
        <td>${u.userId}</td>
        <td>${u.email}</td>
        <td>${u.nickname}</td>
        <td>
                            <span class="badge ${u.role == 'ROLE_ADMIN' ? 'bg-danger' : 'bg-primary'}">
                                ${u.role}
                            </span>
        </td>
        <td>${u.createdAt}</td>
      </tr>
    </c:forEach>
    </tbody>
  </table>
</div>
</body>
</html>