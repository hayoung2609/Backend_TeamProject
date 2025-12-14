<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MavenGuard | 로그인</title>

    <!-- Bootstrap / FontAwesome (index.jsp와 동일) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-light">

<!-- 네비게이션 바 (index.jsp 그대로) -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand fw-bold" href="index.jsp">
            <i class="fas fa-shield-alt"></i> MavenGuard
        </a>
    </div>
</nav>

<div class="container d-flex justify-content-center align-items-center" style="min-height: 80vh;">
    <div class="card shadow-sm" style="width: 400px; border-radius: 12px;">
        <div class="card-body p-4">
            <h4 class="fw-bold text-center mb-4">로그인</h4>

            <div class="mb-3">
                <label class="form-label">이메일</label>
                <input type="email" id="email" class="form-control" placeholder="email@example.com">
            </div>

            <div class="mb-4">
                <label class="form-label">비밀번호</label>
                <input type="password" id="password" class="form-control" placeholder="비밀번호">
            </div>

            <button class="btn btn-dark w-100 rounded-pill" onclick="login()">
                로그인
            </button>

            <div class="text-center mt-3">
                <small class="text-muted">
                    계정이 없으신가요?
                    <a href="register.jsp" class="text-decoration-none fw-bold">회원가입</a>
                </small>
            </div>
        </div>
    </div>
</div>

<script>
    const contextPath = location.pathname.substring(0, location.pathname.indexOf('/', 1));

    function login() {
        fetch(contextPath + '/api/auth/login', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                email: email.value,
                password: password.value
            })
        })
            .then(res => res.json())
            .then(res => {
                if (res.success) {
                    localStorage.setItem('user', JSON.stringify(res));
                    location.href = 'index.jsp';
                } else {
                    alert(res.message);
                }
            });
    }
</script>

</body>
</html>



