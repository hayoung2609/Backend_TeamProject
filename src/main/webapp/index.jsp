<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MavenGuard - 보안 중심의 의존성 관리</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
        .hero-section { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 60px 0; margin-bottom: 30px; }
        .search-box { max-width: 700px; margin: 0 auto; position: relative; }
        .search-input { height: 55px; font-size: 1.1rem; border-radius: 30px; padding-left: 25px; border: none; box-shadow: 0 4px 15px rgba(0,0,0,0.2); }
        .search-btn { position: absolute; right: 5px; top: 5px; height: 45px; border-radius: 25px; padding: 0 25px; font-weight: bold; }

        .workspace-card { border: none; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); height: 100%; }
        .kit-list { height: 400px; overflow-y: auto; background: #fdfdfd; border: 1px solid #eee; border-radius: 8px; }
        .kit-item { padding: 12px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; transition: 0.2s; }
        .kit-item:hover { background-color: #f8f9fa; }

        .badge-safe { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .badge-danger { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        /* 검색 결과 드롭다운 스타일 */
        #searchResult { position: absolute; width: 100%; z-index: 1000; top: 60px; display: none; }
        .result-item { cursor: pointer; }
        .result-item:hover { background-color: #f0f7ff; }
    </style>
</head>
<body>

<!-- 네비게이션 바 -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold" href="index.jsp"><i class="fas fa-shield-alt"></i> MavenGuard</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center">
                <li class="nav-item"><a class="nav-link active" href="index.jsp">홈</a></li>
                <li class="nav-item"><a class="nav-link" href="#" onclick="checkLoginAndMove('my_kit.jsp')">나만의 Kit</a></li>
                <li class="nav-item ms-2" id="authSection">
                    <a class="btn btn-outline-light btn-sm px-3 rounded-pill" href="login.jsp">로그인</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- 히어로 섹션 (검색창) -->
<div class="hero-section text-center">
    <div class="container">
        <h2 class="mb-3 fw-bold">안전한 오픈소스 생태계를 위한 첫걸음</h2>
        <p class="mb-4 opacity-75">Maven 라이브러리를 검색하고 실시간 보안 취약점을 진단하세요.</p>

        <div class="search-box">
            <input type="text" id="keyword" class="form-control search-input" placeholder="라이브러리 검색 (예: spring-boot-starter-web, lombok...)" autocomplete="off">
            <button class="btn btn-warning search-btn" onclick="searchLib()">검색</button>

            <!-- 검색 결과 리스트 (드롭다운처럼 표시) -->
            <div id="searchResult" class="list-group text-start shadow"></div>
        </div>
    </div>
</div>

<div class="container pb-5">
    <div class="row g-4">
        <!-- 왼쪽: 기능 패널 -->
        <div class="col-lg-4">
            <!-- POM 파싱 -->
            <div class="card workspace-card mb-4">
                <div class="card-body">
                    <h5 class="card-title fw-bold mb-3"><i class="fas fa-file-code text-primary"></i> 빠른 가져오기</h5>
                    <p class="text-muted small">기존 pom.xml의 &lt;dependencies&gt; 내용을 붙여넣으세요.</p>
                    <textarea id="pasteArea" class="form-control mb-3" rows="5" style="font-size: 0.85rem; font-family: monospace;"></textarea>
                    <button class="btn btn-outline-primary w-100" onclick="parseAndAdd()">
                        <i class="fas fa-magic"></i> 분석 및 추가
                    </button>
                </div>
            </div>

            <!-- 사용 가이드 -->
            <div class="card workspace-card bg-light">
                <div class="card-body">
                    <h6 class="fw-bold"><i class="fas fa-info-circle"></i> 사용 방법</h6>
                    <ul class="small text-muted ps-3 mb-0">
                        <li>상단 검색창에서 라이브러리를 찾아 추가하세요.</li>
                        <li>[보안 진단]을 눌러 취약점을 검사하세요.</li>
                        <li>로그인하면 나만의 구성을 저장할 수 있습니다.</li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- 오른쪽: 워크스페이스 (Kit 구성) -->
        <div class="col-lg-8">
            <div class="card workspace-card">
                <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                    <h5 class="m-0 fw-bold"><i class="fas fa-layer-group text-success"></i> 현재 구성된 Kit</h5>
                    <div>
                        <button class="btn btn-danger btn-sm me-1" onclick="runSecurityCheck()">
                            <i class="fas fa-virus-slash"></i> 전체 보안 진단
                        </button>
                        <button class="btn btn-outline-secondary btn-sm" onclick="clearKit()">초기화</button>
                    </div>
                </div>

                <div class="card-body">
                    <!-- 담긴 라이브러리 목록 -->
                    <div id="myKitList" class="kit-list mb-3 p-2">
                        <div class="text-center text-muted py-5 mt-5">
                            <i class="fas fa-box-open fa-3x mb-3 opacity-25"></i>
                            <p>선택된 라이브러리가 없습니다.</p>
                        </div>
                    </div>

                    <!-- 하단 액션 (저장/복사) -->
                    <div class="row g-2 align-items-end">
                        <div class="col-md-7">
                            <label class="form-label small fw-bold text-secondary">Kit 제목 (저장 시 필수)</label>
                            <input type="text" id="kitTitle" class="form-control" placeholder="예: 쇼핑몰 프로젝트 v1.0">
                        </div>
                        <div class="col-md-5 d-flex gap-2">
                            <button class="btn btn-dark flex-grow-1" onclick="copyXml()">
                                <i class="fas fa-copy"></i> XML 복사
                            </button>
                            <button class="btn btn-success flex-grow-1" onclick="saveKit()">
                                <i class="fas fa-save"></i> Kit 저장
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Context Path 자동 감지
    const getContextPath = () => {
        const hostIndex = location.href.indexOf(location.host) + location.host.length;
        const contextPath = location.href.substring(hostIndex, location.href.indexOf('/', hostIndex + 1));
        return contextPath === "/index.jsp" ? "" : contextPath;
    };
    const contextPath = getContextPath();

    let currentKitItems = [];

    // --- 1. 초기화 및 로그인 상태 관리 ---
    const userJson = localStorage.getItem('user');
    const user = userJson ? JSON.parse(userJson) : null;

    window.onload = function() {
        // 로그인 상태면 상단 버튼 변경
        if (user) {
            document.getElementById('authSection').innerHTML = `
                <div class="dropdown">
                    <button class="btn btn-outline-light btn-sm dropdown-toggle rounded-pill px-3" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-user-circle"></i> \${user.nickname}
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="my_kit.jsp">내 보관함</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="#" onclick="logout()">로그아웃</a></li>
                    </ul>
                </div>
            `;
        }

        // 검색창 엔터키 이벤트
        document.getElementById('keyword').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') searchLib();
        });
    };

    function logout() {
        if(confirm('로그아웃 하시겠습니까?')) {
            localStorage.removeItem('user');
            location.reload();
        }
    }

    function checkLoginAndMove(url) {
        if (!user) {
            if(confirm("로그인이 필요한 서비스입니다.\n로그인 페이지로 이동하시겠습니까?")) {
                location.href = 'login.jsp';
            }
        } else {
            location.href = url;
        }
    }

    // --- 2. 라이브러리 검색 ---
    function searchLib() {
        const keyword = document.getElementById('keyword').value.trim();
        if (!keyword) return alert("검색어를 입력하세요.");

        const resultDiv = document.getElementById('searchResult');
        resultDiv.style.display = 'block';
        resultDiv.innerHTML = '<div class="list-group-item text-center p-3"><div class="spinner-border text-primary spinner-border-sm"></div> 검색중...</div>';

        fetch(contextPath + '/api/libraries/search?q=' + encodeURIComponent(keyword))
            .then(res => res.json())
            .then(data => {
                resultDiv.innerHTML = '';
                if (data.length === 0) {
                    resultDiv.innerHTML = '<div class="list-group-item text-center">검색 결과가 없습니다.</div>';
                    setTimeout(() => resultDiv.style.display = 'none', 2000);
                    return;
                }

                // 닫기 버튼 추가
                const closeBtn = document.createElement('div');
                closeBtn.className = 'list-group-item bg-light text-end p-1';
                closeBtn.innerHTML = '<button class="btn-close btn-sm" onclick="document.getElementById(\'searchResult\').style.display=\'none\'"></button>';
                resultDiv.appendChild(closeBtn);

                data.forEach(item => {
                    const el = document.createElement('a');
                    el.className = 'list-group-item list-group-item-action result-item';
                    el.innerHTML = `
                        <div class="d-flex w-100 justify-content-between align-items-center">
                            <div>
                                <span class="fw-bold text-primary">\${item.artifactId}</span>
                                <small class="text-muted ms-2">\${item.groupId}</small>
                            </div>
                            <span class="badge bg-secondary rounded-pill">\${item.latestVersion}</span>
                        </div>
                    `;
                    el.onclick = () => {
                        addItemToKit(item.groupId, item.artifactId, item.latestVersion);
                        resultDiv.style.display = 'none';
                        document.getElementById('keyword').value = '';
                    };
                    resultDiv.appendChild(el);
                });
            })
            .catch(err => {
                console.error(err);
                resultDiv.innerHTML = '<div class="list-group-item text-danger">서버 통신 오류</div>';
            });
    }

    // --- 3. Kit 아이템 관리 ---
    function addItemToKit(groupId, artifactId, version) {
        const exists = currentKitItems.some(i => i.groupId === groupId && i.artifactId === artifactId);
        if (exists) return alert("이미 추가된 라이브러리입니다.");

        currentKitItems.push({ groupId, artifactId, version, status: 'unknown' });
        renderKit();
    }

    // 3. 화면 그리기 (렌더링)
    function renderKit() {
        const listDiv = document.getElementById('myKitList');
        if (currentKitItems.length === 0) {
            listDiv.innerHTML = '<div class="text-center text-muted py-5 mt-5"><i class="fas fa-box-open fa-3x mb-3 opacity-25"></i><p>선택된 라이브러리가 없습니다.</p></div>';
            return;
        }
        listDiv.innerHTML = '';

        currentKitItems.forEach((item, index) => {
            let badgeClass = 'bg-secondary';
            let badgeText = '미진단';

            if (item.status === 'safe') { badgeClass = 'badge-safe'; badgeText = '<i class="fas fa-check"></i> 안전'; }
            if (item.status === 'danger') { badgeClass = 'badge-danger'; badgeText = '<i class="fas fa-exclamation-triangle"></i> 위험'; }

            const div = document.createElement('div');
            div.className = 'kit-item';
            div.innerHTML = `
                <div>
                    <div class="fw-bold text-dark">\${item.artifactId}</div>
                    <div class="small text-muted">\${item.groupId} : \${item.version}</div>
                </div>
                <div class="text-end d-flex align-items-center gap-2">
                    <span class="badge \${badgeClass}">\${badgeText}</span>
                    <button class="btn btn-sm btn-outline-danger rounded-circle" onclick="removeItem(\${index})"><i class="fas fa-times"></i></button>
                </div>
            `;
            listDiv.appendChild(div);
        });
    }

    function removeItem(index) {
        currentKitItems.splice(index, 1);
        renderKit();
    }

    function clearKit() {
        if(confirm('정말 초기화 하시겠습니까?')) {
            currentKitItems = [];
            renderKit();
        }
    }

    // --- 4. POM 파싱 ---
    function parseAndAdd() {
        const xml = document.getElementById('pasteArea').value;
        if(!xml.trim()) return alert("내용을 입력하세요.");

        fetch(contextPath + '/api/libraries/parse', {
            method: 'POST',
            headers: { 'Content-Type': 'text/plain' },
            body: xml
        })
            .then(res => res.json())
            .then(data => {
                let count = 0;
                data.forEach(item => {
                    const ver = item.currentVersion || item.latestVersion;
                    const exists = currentKitItems.some(i => i.groupId === item.groupId && i.artifactId === item.artifactId);
                    if (!exists) {
                        currentKitItems.push({ groupId: item.groupId, artifactId: item.artifactId, version: ver, status: 'unknown' });
                        count++;
                    }
                });
                renderKit();
                alert(count + "개의 라이브러리가 추가되었습니다.");
                document.getElementById('pasteArea').value = '';
            })
            .catch(err => alert("파싱 실패: " + err));
    }

    // --- 5. 보안 진단 (핵심) ---
    async function runSecurityCheck() {
        if (currentKitItems.length === 0) return alert("진단할 라이브러리가 없습니다.");

        // 로딩 표시
        const originalBtnText = document.querySelector('button[onclick="runSecurityCheck()"]').innerHTML;
        document.querySelector('button[onclick="runSecurityCheck()"]').innerHTML = '<span class="spinner-border spinner-border-sm"></span> 진단중...';

        let dangerCount = 0;

        for (let i = 0; i < currentKitItems.length; i++) {
            const item = currentKitItems[i];
            try {
                const response = await fetch(contextPath + '/api/libraries/check', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ groupId: item.groupId, artifactId: item.artifactId, version: item.version })
                });
                const result = await response.json();

                // 결과 업데이트
                currentKitItems[i].status = result.safe ? 'safe' : 'danger';
                if(!result.safe) dangerCount++;
            } catch (e) {
                console.error(e);
            }
        }
        renderKit(); // 상태 변경 후 다시 그리기
        document.querySelector('button[onclick="runSecurityCheck()"]').innerHTML = originalBtnText;

        if(dangerCount > 0) alert("⚠️ " + dangerCount + "개의 취약한 라이브러리가 발견되었습니다!");
        else alert("✅ 모든 라이브러리가 안전합니다.");
    }

    // --- 6. Kit 저장 ---
    function saveKit() {
        // 비로그인 시 로그인 페이지로 유도
        if (!user) {
            if(confirm("Kit 저장은 로그인이 필요한 서비스입니다.\n지금 로그인 하시겠습니까?")) {
                location.href = 'login.jsp';
            }
            return;
        }

        const title = document.getElementById('kitTitle').value.trim();
        if (!title) return alert("Kit 제목을 입력하세요.");
        if (currentKitItems.length === 0) return alert("저장할 라이브러리가 없습니다.");

        const data = {
            userId: user.userId,
            title: title,
            description: "웹에서 생성된 Kit (" + new Date().toLocaleString() + ")",
            isPublic: true,
            itemList: currentKitItems
        };

        fetch(contextPath + '/api/kits', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        })
            .then(res => res.text())
            .then(text => {
                alert("✅ 성공적으로 저장되었습니다!");
                if(confirm("보관함으로 이동해서 확인하시겠습니까?")) {
                    location.href = 'my_kit.jsp';
                }
            })
            .catch(err => alert("저장 실패: " + err));
    }

    // --- 7. XML 복사 ---
    function copyXml() {
        if (currentKitItems.length === 0) return alert("복사할 내용이 없습니다.");

        let xml = "<dependencies>\n";
        currentKitItems.forEach(item => {
            xml += `    <dependency>
        <groupId>\${item.groupId}</groupId>
        <artifactId>\${item.artifactId}</artifactId>
        <version>\${item.version}</version>
    </dependency>\n`;
        });
        xml += "</dependencies>";

        navigator.clipboard.writeText(xml).then(() => {
            alert("클립보드에 복사되었습니다! pom.xml에 붙여넣으세요.");
        });
    }
</script>
</body>
</html>