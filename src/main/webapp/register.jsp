<div class="card-body p-4">
    <h4 class="fw-bold text-center mb-4">회원가입</h4>

    <div class="mb-3">
        <label class="form-label">이메일</label>
        <input type="email" id="email" class="form-control" required>
    </div>

    <div class="mb-3">
        <label class="form-label">닉네임</label>
        <input type="text" id="nickname" class="form-control" placeholder="사용할 이름을 입력하세요" required>
    </div>

    <div class="mb-4">
        <label class="form-label">비밀번호</label>
        <input type="password" id="password" class="form-control" required>
    </div>

    <button class="btn btn-success w-100 rounded-pill" onclick="register()">
        회원가입
    </button>
</div>

<script>
    const contextPath = location.pathname.substring(0, location.pathname.indexOf('/', 1));

    function register() {
        const email = document.getElementById('email').value;
        const nickname = document.getElementById('nickname').value;
        const password = document.getElementById('password').value;

        // [가이드 준수] 프론트엔드 유효성 검사
        if(!email || !nickname || !password) {
            alert("모든 항목을 입력해주세요.");
            return;
        }

        fetch(contextPath + '/api/auth/register', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                email: email,
                password: password,
                nickname: nickname // [수정] 닉네임 전송 추가
            })
        })
            .then(res => res.json())
            .then(res => {
                if (res.success) {
                    alert("회원가입 완료!");
                    location.href = 'login.jsp';
                } else {
                    // 백엔드 에러 메시지 출력
                    alert(res.message || "회원가입 실패");
                }
            })
            .catch(err => alert("오류 발생: " + err));
    }
</script>