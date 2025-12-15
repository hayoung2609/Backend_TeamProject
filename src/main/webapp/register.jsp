<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MavenGuard | 회원가입</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand fw-bold" href="index.jsp">
            <i class="fas fa-shield-alt"></i> MavenGuard
        </a>
    </div>
</nav>

<div class="container d-flex justify-content-center align-items-center" style="min-height: 80vh;">
    <div class="card shadow-sm" style="width: 400px; border-radius: 12px;">
        <div class="card-body p-4">
            <h4 class="fw-bold text-center mb-4">회원가입</h4>

            <div class="mb-3">
                <label class="form-label">이메일</label>
                <input type="email" id="email" class="form-control">
            </div>

            <div class="mb-3">
                <label class="form-label">닉네임</label>
                <input type="text" id="nickname" class="form-control" placeholder="사용할 이름을 입력하세요">
            </div>

            <div class="mb-4">
                <label class="form-label">비밀번호</label>
                <input type="password" id="password" class="form-control">
            </div>

            <button class="btn btn-success w-100 rounded-pill" onclick="register()">
                회원가입
            </button>
        </div>
    </div>
</div>

<script>
    const contextPath = location.pathname.substring(0, location.pathname.indexOf('/', 1));

    function register() {
        fetch(contextPath + '/api/auth/register', {
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
                    alert("회원가입 완료!");
                    location.href = 'login.jsp';
                }
            });
    }
</script>

</body>
</html>


