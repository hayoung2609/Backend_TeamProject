<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MavenGuard - Create Account</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">

    <style>
        /* --- Login.jsp와 동일한 디자인 시스템 --- */
        :root {
            --bg-body: #f8fafc;
            --surface-color: #ffffff;
            --primary-dark: #0f172a;
            --primary-accent: #3b82f6;
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
        }

        /* Register Card */
        .register-card {
            background: var(--surface-color);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            box-shadow: var(--shadow-soft);
            padding: 2.5rem;
            transition: transform 0.3s;
        }
        .register-card:hover {
            box-shadow: 0 20px 40px -5px rgba(0, 0, 0, 0.1);
        }

        /* Form Controls */
        .form-label {
            font-weight: 600;
            font-size: 0.9rem;
            color: var(--text-main);
            margin-bottom: 0.5rem;
        }
        .input-group-text {
            background: #fff;
            border: 2px solid #e2e8f0;
            border-right: none;
            border-radius: 12px 0 0 12px;
            color: var(--text-sub);
        }
        .form-control-custom {
            border: 2px solid #e2e8f0;
            border-left: none;
            border-radius: 0 12px 12px 0;
            padding: 0.8rem 1rem;
            font-size: 1rem;
            transition: all 0.2s;
        }
        .form-control-custom:focus {
            border-color: var(--primary-accent);
            box-shadow: none;
            outline: none;
        }
        .input-group:focus-within .input-group-text {
            border-color: var(--primary-accent);
        }
        .input-group:focus-within .form-control-custom {
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
        }

        /* Button */
        .btn-register {
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
            border: none;
            padding: 12px;
            font-weight: 600;
            font-size: 1.05rem;
            border-radius: 12px;
            color: white;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);
            transition: all 0.3s;
        }
        .btn-register:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(37, 99, 235, 0.3);
            color: white;
        }
    </style>
</head>
<body>

<nav class="navbar sticky-top">
    <div class="container">
        <a class="navbar-brand brand-logo" href="index.jsp">
            <span class="fa-stack" style="font-size: 0.8em;">
              <i class="fas fa-circle fa-stack-2x" style="color: rgba(59, 130, 246, 0.1);"></i>
              <i class="fas fa-shield-halved fa-stack-1x text-primary"></i>
            </span>
            MavenGuard
        </a>
    </div>
</nav>

<div class="container d-flex justify-content-center align-items-center" style="min-height: 85vh; padding-bottom: 2rem;">
    <div class="register-card" style="width: 100%; max-width: 450px;">
        <div class="text-center mb-4">
            <div class="bg-primary bg-opacity-10 text-primary rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 60px; height: 60px;">
                <i class="fas fa-user-plus fa-xl"></i>
            </div>
            <h4 class="fw-bold" style="color: var(--primary-dark);">Create Account</h4>
            <p class="text-secondary small">안전한 개발 환경을 위한 첫 걸음</p>
        </div>

        <div class="mb-3">
            <label class="form-label">Email Address</label>
            <div class="input-group">
                <span class="input-group-text"><i class="far fa-envelope"></i></span>
                <input type="email" id="email" class="form-control form-control-custom" placeholder="name@example.com" required>
            </div>
        </div>

        <div class="mb-3">
            <label class="form-label">Nickname</label>
            <div class="input-group">
                <span class="input-group-text"><i class="far fa-user"></i></span>
                <input type="text" id="nickname" class="form-control form-control-custom" placeholder="What should we call you?" required>
            </div>
        </div>

        <div class="mb-4">
            <label class="form-label">Password</label>
            <div class="input-group">
                <span class="input-group-text"><i class="fas fa-lock"></i></span>
                <input type="password" id="password" class="form-control form-control-custom" placeholder="Min. 4 characters" required>
            </div>
        </div>

        <button class="btn btn-register w-100 mb-3" onclick="register()">
            Sign Up
        </button>

        <div class="text-center">
            <span class="text-muted small">Already have an account?</span>
            <a href="login.jsp" class="fw-bold text-decoration-none ms-1 text-primary">Sign In</a>
        </div>
    </div>
</div>

<script>
    const contextPath = "${pageContext.request.contextPath}";

    function register() {
        const email = document.getElementById('email').value.trim();
        const nickname = document.getElementById('nickname').value.trim();
        const password = document.getElementById('password').value.trim();

        // 1. 유효성 검사
        if(!email || !nickname || !password) {
            alert("모든 항목을 입력해주세요.");
            return;
        }

        if(!email.includes('@')) {
            alert("올바른 이메일 형식이 아닙니다.");
            return;
        }

        if(password.length < 4) {
            alert("비밀번호는 최소 4자 이상이어야 합니다.");
            return;
        }

        // 2. 버튼 로딩 상태
        const btn = document.querySelector('.btn-register');
        const orgText = btn.innerHTML;
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Creating Account...';

        // 3. API 호출
        fetch(contextPath + '/api/auth/register', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                email: email,
                password: password,
                nickname: nickname
            })
        })
            .then(res => res.json())
            .then(res => {
                if (res.success) {
                    alert("회원가입이 완료되었습니다! 🎉\n로그인 페이지로 이동합니다.");
                    location.href = 'login.jsp';
                } else {
                    alert(res.message || "회원가입에 실패했습니다.");
                    btn.disabled = false;
                    btn.innerHTML = orgText;
                }
            })
            .catch(err => {
                console.error(err);
                alert("서버 통신 중 오류가 발생했습니다.");
                btn.disabled = false;
                btn.innerHTML = orgText;
            });
    }

    // 엔터키 입력 시 가입 실행
    document.getElementById('password').addEventListener('keypress', function (e) {
        if (e.key === 'Enter') register();
    });
</script>

</body>
</html>