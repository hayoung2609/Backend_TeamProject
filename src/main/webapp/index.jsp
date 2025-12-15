<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MavenGuard - Secure Dependency Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --bg-color: #f4f6f9; --text-main: #2c3e50; --primary: #2980b9; --accent: #27ae60; --danger: #e74c3c;
        }
        body { background-color: var(--bg-color); color: var(--text-main); font-family: 'Inter', sans-serif; }
        .navbar { padding: 15px 0; }
        .navbar-brand { font-weight: 800; font-size: 1.5rem; color: var(--text-main) !important; }

        .main-card {
            background: white; border-radius: 20px; box-shadow: 0 10px 40px rgba(0,0,0,0.08);
            padding: 40px; max-width: 800px; margin: 50px auto; text-align: center;
        }

        /* 탭 스타일 */
        .nav-pills .nav-link {
            color: #bdc3c7; font-weight: 600; border-radius: 50px; padding: 10px 25px;
        }
        .nav-pills .nav-link.active { background-color: var(--text-main); color: white; }

        /* 검색창 */
        .search-input {
            border: 2px solid #eee; padding: 15px 20px; border-radius: 12px; width: 100%; font-family: 'JetBrains Mono';
        }
        .search-input:focus { border-color: var(--primary); outline: none; }

        /* 검색 결과 */
        #searchResult {
            text-align: left; margin-top: 10px; max-height: 300px; overflow-y: auto;
            border: 1px solid #eee; border-radius: 12px; display: none;
        }
        .result-item { padding: 15px; border-bottom: 1px solid #f1f1f1; cursor: pointer; transition: 0.2s; }
        .result-item:hover { background-color: #f8f9fa; border-left: 4px solid var(--primary); }

        /* 태그 */
        .tag-badge {
            background: white; padding: 12px 20px; border-radius: 12px; font-family: 'JetBrains Mono';
            box-shadow: 0 4px 10px rgba(0,0,0,0.05); border-left: 4px solid #bdc3c7;
            display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px;
        }
        .tag-badge.safe { border-left-color: var(--accent); }
        .tag-badge.danger { border-left-color: var(--danger); background: #fff5f5; }

        .version-edit {
            cursor: pointer; border-bottom: 1px dashed #999; margin-left: 10px; color: var(--primary);
        }
        .version-edit:hover { color: var(--text-main); border-bottom-style: solid; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg">
    <div class="container">
        <a class="navbar-brand" href="index.jsp"><i class="fas fa-shield-alt"></i> MavenGuard</a>
        <div class="ms-auto">
            <c:if test="${empty sessionScope.loginUser}">
                <a href="login.jsp" class="btn btn-primary btn-sm rounded-pill px-4">Sign In</a>
            </c:if>
            <c:if test="${not empty sessionScope.loginUser}">
                <span class="fw-bold me-3">Hi, ${sessionScope.loginUser.name}</span>
                <a href="/kits/my" class="btn btn-outline-primary btn-sm rounded-pill">My Kits</a>
                <button onclick="logout()" class="btn btn-link btn-sm text-secondary text-decoration-none">Logout</button>
            </c:if>
        </div>
    </div>
</nav>

<div class="container">
    <div class="main-card">
        <h2 class="fw-bold mb-2">Secure Dependencies</h2>
        <p class="text-muted mb-4">검색하거나 기존 pom.xml을 붙여넣어 보안을 진단하세요.</p>

        <ul class="nav nav-pills justify-content-center mb-4" id="pills-tab" role="tablist">
            <li class="nav-item">
                <button class="nav-link active" id="pills-search-tab" data-bs-toggle="pill" data-bs-target="#pills-search" type="button">
                    <i class="fas fa-search"></i> 검색하기
                </button>
            </li>
            <li class="nav-item">
                <button class="nav-link" id="pills-paste-tab" data-bs-toggle="pill" data-bs-target="#pills-paste" type="button">
                    <i class="fas fa-code"></i> pom.xml 붙여넣기
                </button>
            </li>
        </ul>

        <div class="tab-content" id="pills-tabContent">
            <div class="tab-pane fade show active" id="pills-search">
                <div class="position-relative">
                    <input type="text" id="keyword" class="search-input" placeholder="라이브러리 검색 (예: spring-boot, jackson)..." autocomplete="off">
                    <div id="searchResult"></div>
                </div>
            </div>

            <div class="tab-pane fade" id="pills-paste">
                <textarea id="pomArea" class="form-control mb-3" rows="6" placeholder="<dependencies>...</dependencies> 내용을 여기에 붙여넣으세요." style="font-family: 'JetBrains Mono'; font-size: 0.9rem; background: #f8f9fa;"></textarea>
                <button class="btn btn-dark w-100" onclick="parsePom()">
                    <i class="fas fa-file-import"></i> 가져오기 및 분석
                </button>
            </div>
        </div>

        <div id="workspace" class="mt-5 text-start" style="display:none;">
            <h5 class="fw-bold mb-3"><i class="fas fa-layer-group"></i> Selected Libraries</h5>
            <div id="tagContainer"></div>

            <div class="d-flex justify-content-center gap-2 mt-4">
                <button class="btn btn-primary rounded-pill px-4" onclick="runSecurityCheck()">
                    <i class="fas fa-virus-slash"></i> 보안 진단 실행
                </button>
                <button class="btn btn-outline-dark rounded-pill px-4" onclick="copyXml()">
                    <i class="fas fa-copy"></i> XML 복사
                </button>
                <button class="btn btn-success rounded-pill px-4" onclick="saveKit()">
                    <i class="fas fa-save"></i> 저장
                </button>
            </div>

            <div id="saveForm" class="mt-3 text-center" style="display:none;">
                <input type="text" id="kitTitle" class="form-control d-inline-block w-auto text-center" placeholder="Project Name">
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="vulnModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold text-danger"><i class="fas fa-exclamation-triangle"></i> 취약점 발견</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <h6 id="modalTitle" class="fw-bold"></h6>
                <p id="modalDetail" class="alert alert-light border mt-2"></p>
                <div class="d-flex justify-content-between align-items-center mt-3">
                    <span class="text-success fw-bold">추천 버전: <span id="modalFix"></span></span>
                    <button id="btnFix" class="btn btn-sm btn-success px-3 rounded-pill">업데이트 적용</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const contextPath = "${pageContext.request.contextPath}";
    let items = [];
    const vulnModal = new bootstrap.Modal(document.getElementById('vulnModal'));
    let selectedIndex = -1;

    // --- 1. 검색 ---
    let timer;
    document.getElementById('keyword').addEventListener('input', function() {
        clearTimeout(timer);
        timer = setTimeout(() => {
            const q = this.value.trim();
            const resDiv = document.getElementById('searchResult');
            if(!q) { resDiv.style.display='none'; return; }

            fetch(contextPath + '/api/libraries/search?q=' + encodeURIComponent(q))
                .then(res => res.json())
                .then(data => {
                    resDiv.innerHTML = '';
                    if(data.length === 0) return;
                    data.forEach(item => {
                        const el = document.createElement('div');
                        el.className = 'result-item';
                        // 검색 결과 디자인 개선
                        el.innerHTML = `
                            <div class="d-flex justify-content-between">
                                <div>
                                    <div class="fw-bold text-dark">\${item.artifactId}</div>
                                    <small class="text-muted">\${item.groupId}</small>
                                </div>
                                <div class="text-end">
                                    <span class="badge bg-light text-dark border">\${item.latestVersion}</span>
                                    <div style="font-size:0.75rem" class="text-secondary mt-1">Latest</div>
                                </div>
                            </div>`;
                        el.onclick = () => {
                            addItem(item.groupId, item.artifactId, item.latestVersion);
                            resDiv.style.display = 'none';
                            this.value = '';
                        };
                        resDiv.appendChild(el);
                    });
                    resDiv.style.display = 'block';
                });
        }, 300);
    });

    // --- 2. 붙여넣기 (Parse) ---
    function parsePom() {
        const xml = document.getElementById('pomArea').value;
        if(!xml.trim()) return alert("XML 내용을 입력하세요.");

        fetch(contextPath + '/api/libraries/parse', {
            method: 'POST', headers: {'Content-Type': 'text/plain'}, body: xml
        })
            .then(res => res.json())
            .then(data => {
                data.forEach(item => addItem(item.groupId, item.artifactId, item.latestVersion)); // parsePomXml에서 latestVersion 필드에 버전을 담아줌
                document.getElementById('pomArea').value = '';
                alert(data.length + "개의 라이브러리를 불러왔습니다.");
            });
    }

    // --- 3. 공통 아이템 관리 ---
    function addItem(g, a, v) {
        if(items.some(i => i.g === g && i.a === a)) return;
        items.push({ g: g, a: a, v: v, status: 'unknown' });
        render();
    }

    function render() {
        const container = document.getElementById('tagContainer');
        const workspace = document.getElementById('workspace');
        container.innerHTML = '';

        if(items.length > 0) workspace.style.display = 'block';
        else workspace.style.display = 'none';

        items.forEach((item, idx) => {
            let statusBadge = '';
            let statusClass = '';
            let action = '';

            if(item.status === 'safe') {
                statusClass = 'safe';
                statusBadge = '<i class="fas fa-check-circle text-success ms-2"></i>';
            } else if(item.status === 'danger') {
                statusClass = 'danger';
                statusBadge = '<i class="fas fa-exclamation-triangle text-danger ms-2"></i>';
                action = `onclick="openModal(\${idx})"`;
            }

            const el = document.createElement('div');
            el.className = `tag-badge \${statusClass}`;
            if(action) el.setAttribute('onclick', `openModal(\${idx})`);

            // 버전 클릭 시 수정 가능하도록
            el.innerHTML = `
                <div>
                    <span class="fw-bold">\${item.a}</span>
                    <span class="small text-muted ms-1">(\${item.g})</span>
                </div>
                <div class="d-flex align-items-center">
                    <span class="version-edit" onclick="editVersion(\${idx}, event)" title="Click to change version">\${item.v}</span>
                    \${statusBadge}
                    <i class="fas fa-times text-secondary ms-3" style="cursor:pointer" onclick="removeItem(\${idx}, event)"></i>
                </div>
            `;
            container.appendChild(el);
        });
    }

    function removeItem(idx, e) {
        if(e) e.stopPropagation();
        items.splice(idx, 1);
        render();
    }

    // [기능추가] 버전 직접 수정
    function editVersion(idx, e) {
        if(e) e.stopPropagation();
        const newVer = prompt("사용할 버전을 입력하세요:", items[idx].v);
        if(newVer && newVer.trim() !== "") {
            items[idx].v = newVer.trim();
            items[idx].status = 'unknown'; // 버전 바뀌면 다시 진단해야 함
            render();
        }
    }

    // --- 4. 보안 진단 ---
    async function runSecurityCheck() {
        const btn = document.querySelector('button[onclick="runSecurityCheck()"]');
        const orgHtml = btn.innerHTML;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 진단 중...';

        for(let i=0; i<items.length; i++) {
            try {
                const res = await fetch(contextPath + '/api/libraries/check', {
                    method:'POST', headers:{'Content-Type':'application/json'},
                    body: JSON.stringify({groupId: items[i].g, artifactId: items[i].a, version: items[i].v})
                });
                const data = await res.json();
                items[i].status = data.safe ? 'safe' : 'danger';
                if(!data.safe) {
                    items[i].detail = data.detail;
                    items[i].fix = data.fixedVersion;
                }
            } catch(e) {}
        }
        render();
        btn.innerHTML = orgHtml;
    }

    // --- 5. 모달 및 Fix ---
    function openModal(idx) {
        selectedIndex = idx;
        const item = items[idx];
        document.getElementById('modalTitle').innerText = item.a + " (" + item.v + ")";
        document.getElementById('modalDetail').innerText = item.detail || "상세 정보 없음";
        document.getElementById('modalFix').innerText = item.fix || "정보 없음";

        const btn = document.getElementById('btnFix');
        if(item.fix && item.fix !== '정보 없음') {
            btn.disabled = false;
            btn.onclick = () => {
                items[idx].v = item.fix;
                items[idx].status = 'safe'; // 수정했으니 안전으로 처리
                render();
                vulnModal.hide();
            };
        } else {
            btn.disabled = true;
        }
        vulnModal.show();
    }

    // --- 6. XML 복사 및 저장 ---
    function copyXml() {
        if(items.length===0) return;
        let xml = "<dependencies>\n";
        items.forEach(i => xml += `    <dependency>\n        <groupId>\${i.g}</groupId>\n        <artifactId>\${i.a}</artifactId>\n        <version>\${i.v}</version>\n    </dependency>\n`);
        xml += "</dependencies>";
        navigator.clipboard.writeText(xml).then(()=>alert("복사되었습니다!"));
    }

    function saveKit() {
        const form = document.getElementById('saveForm');
        if(form.style.display === 'none') { form.style.display='block'; document.getElementById('kitTitle').focus(); return; }

        const title = document.getElementById('kitTitle').value;
        if(!title) return alert("제목을 입력하세요.");

        const userId = "${sessionScope.loginUser.userId}";
        if(!userId) { if(confirm("로그인이 필요합니다.")) location.href='login.jsp'; return; }

        const itemList = items.map(i => ({groupId: i.g, artifactId: i.a, version: i.v}));
        fetch(contextPath + '/kits', {
            method:'POST', headers:{'Content-Type':'application/json'},
            body: JSON.stringify({userId: userId, title: title, description: "Generated", isPublic: true, itemList: itemList})
        }).then(() => { alert("저장되었습니다."); location.href = '/kits/my'; });
    }

    function logout() { fetch(contextPath+'/api/auth/logout', {method:'POST'}).then(()=>location.reload()); }
</script>
</body>
</html>