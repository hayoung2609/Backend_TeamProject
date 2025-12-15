<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MavenGuard - My Kits</title>

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
            --danger-bg: #fef2f2;
            --success-color: #10b981;
            --success-bg: #f0fdf4;
            --text-main: #334155;
            --text-sub: #64748b;
            --border-color: #e2e8f0;
            --font-ui: 'Inter', sans-serif;
            --font-code: 'JetBrains Mono', monospace;
            --shadow-soft: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-glow: 0 0 15px rgba(59, 130, 246, 0.15);
        }

        body { background-color: var(--bg-body); color: var(--text-main); font-family: var(--font-ui); -webkit-font-smoothing: antialiased; }

        /* Navbar */
        .navbar { background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(10px); border-bottom: 1px solid var(--border-color); padding: 1rem 0; }
        .brand-logo { font-family: var(--font-code); font-weight: 700; font-size: 1.35rem; color: var(--primary-dark); letter-spacing: -0.03em; display: flex; align-items: center; gap: 10px; }
        .user-pill { background: #f8fafc; border: 1px solid var(--border-color); padding: 6px 16px; border-radius: 999px; font-size: 0.9rem; font-weight: 500; transition: all 0.2s; }
        .user-pill:hover { border-color: var(--primary-accent); color: var(--primary-accent); }

        /* Left Side: Kit List */
        .kit-list-card { background: var(--surface-color); border: 1px solid var(--border-color); border-radius: 16px; overflow: hidden; box-shadow: var(--shadow-soft); height: calc(100vh - 140px); display: flex; flex-direction: column; }
        .kit-list-header { padding: 1.25rem; border-bottom: 1px solid var(--border-color); background: #fff; font-weight: 700; color: var(--primary-dark); }
        .kit-list-body { overflow-y: auto; flex: 1; padding: 0.5rem; }
        .kit-item { padding: 1rem; border-radius: 12px; border: 1px solid transparent; cursor: pointer; transition: all 0.2s; margin-bottom: 4px; }
        .kit-item:hover { background: #f1f5f9; }
        .kit-item.active { background: #eff6ff; border-color: #bfdbfe; }
        .kit-item.active .kit-title { color: var(--primary-accent); }
        .kit-title { font-weight: 600; font-size: 1rem; color: var(--text-main); margin-bottom: 4px; }
        .kit-meta { font-size: 0.8rem; color: var(--text-sub); display: flex; align-items: center; gap: 8px; }

        /* Right Side: Detail View */
        .detail-area { height: calc(100vh - 140px); overflow-y: auto; padding-right: 4px; }
        .empty-state { height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; color: var(--text-sub); text-align: center; }
        .detail-header { background: var(--surface-color); padding: 1.5rem; border-radius: 16px; border: 1px solid var(--border-color); box-shadow: var(--shadow-soft); margin-bottom: 1.5rem; display: flex; justify-content: space-between; align-items: center; }
        .detail-title h2 { font-weight: 800; font-size: 1.5rem; color: var(--primary-dark); margin: 0; letter-spacing: -0.02em; }
        .detail-desc { color: var(--text-sub); margin-top: 4px; font-size: 0.95rem; }

        /* Grid Layout for Dependencies (Same as index.jsp) */
        .dep-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 16px; padding-bottom: 2rem; }
        .dep-item { background: white; border: 1px solid var(--border-color); border-radius: 12px; padding: 1.25rem; transition: all 0.2s; display: flex; flex-direction: column; gap: 10px; position: relative; overflow: hidden; }
        .dep-item:hover { transform: translateY(-3px); box-shadow: 0 10px 20px -5px rgba(0,0,0,0.1); border-color: #cbd5e1; }
        .dep-item::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: #cbd5e1; transition: 0.3s; }
        .dep-item.safe::before { background: var(--success-color); }
        .dep-item.safe { background: linear-gradient(to right, var(--success-bg), white 40%); border-color: #bbf7d0; }
        .dep-item.danger::before { background: var(--danger-color); }
        .dep-item.danger { background: linear-gradient(to right, var(--danger-bg), white 40%); border-color: #fecaca; }

        .lib-name { font-family: var(--font-code); font-weight: 700; color: var(--primary-dark); font-size: 1rem; word-break: break-all; }
        .lib-group { font-size: 0.8rem; color: var(--text-sub); }
        .ver-badge { font-family: var(--font-code); background: #f1f5f9; color: var(--text-main); padding: 3px 8px; border-radius: 6px; font-size: 0.8rem; border: 1px solid #e2e8f0; }

        /* Buttons */
        .btn-action { padding: 8px 16px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; transition: 0.2s; border: 1px solid transparent; }
        .btn-outline-custom { background: white; border-color: var(--border-color); color: var(--text-main); }
        .btn-outline-custom:hover { border-color: var(--primary-accent); color: var(--primary-accent); background: #eff6ff; }
        .btn-primary-custom { background: var(--primary-accent); color: white; box-shadow: 0 4px 10px rgba(59, 130, 246, 0.25); }
        .btn-primary-custom:hover { background: #2563eb; transform: translateY(-1px); box-shadow: 0 6px 15px rgba(59, 130, 246, 0.35); color: white; }

        /* Modal & Scrollbar */
        .modal-content { border: none; border-radius: 24px; box-shadow: 0 20px 50px -12px rgba(0, 0, 0, 0.25); }
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
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
        <div class="d-flex align-items-center gap-3">
            <c:if test="${not empty sessionScope.loginUser}">
                <div class="dropdown">
                    <button class="user-pill dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-user-astronaut me-2 text-secondary"></i>${sessionScope.loginUser.name}
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg mt-2 rounded-4 p-2">
                        <li><a class="dropdown-item rounded-3 active" href="#"><i class="fas fa-box-archive me-2"></i>Saved Kits</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><button class="dropdown-item rounded-3 text-danger" onclick="logout()"><i class="fas fa-power-off me-2"></i>Log Out</button></li>
                    </ul>
                </div>
            </c:if>
        </div>
    </div>
</nav>

<div class="container py-4">
    <div class="row g-4">
        <div class="col-lg-4 col-md-5">
            <div class="kit-list-card">
                <div class="kit-list-header d-flex justify-content-between align-items-center">
                    <span><i class="fas fa-layer-group me-2 text-primary"></i>My Kits</span>
                    <span class="badge bg-secondary bg-opacity-10 text-secondary rounded-pill">${kitList.size()}</span>
                </div>
                <div class="kit-list-body">
                    <c:forEach var="kit" items="${kitList}">
                        <div class="kit-item" onclick="loadKitDetail(${kit.kitId}, this)">
                            <div class="kit-title">${kit.title}</div>
                            <div class="kit-meta">
                                <span><i class="far fa-calendar me-1"></i><fmt:formatDate value="${kit.createdAt}" pattern="yyyy.MM.dd"/></span>
                                <span class="mx-1">•</span>
                                <span>v${kit.projectVersion}</span>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty kitList}">
                        <div class="text-center text-muted mt-5">
                            <i class="fas fa-inbox fa-2x mb-3 opacity-25"></i>
                            <p class="small">저장된 Kit이 없습니다.</p>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

        <div class="col-lg-8 col-md-7">
            <div id="emptyState" class="empty-state">
                <div class="p-5 bg-white rounded-5 border shadow-sm">
                    <i class="fas fa-mouse-pointer fa-3x text-primary opacity-25 mb-4"></i>
                    <h5 class="fw-bold text-dark">Select a Kit</h5>
                    <p class="text-secondary mb-0">왼쪽 목록에서 확인하고 싶은 Kit을 선택하세요.</p>
                </div>
            </div>

            <div id="detailArea" class="detail-area" style="display:none;">
                <div class="detail-header">
                    <div class="detail-title">
                        <h2 id="viewTitle">Kit Title</h2>
                        <div id="viewDesc" class="detail-desc">Description goes here...</div>
                    </div>
                    <div class="d-flex gap-2">
                        <div class="d-flex gap-2">
                            <button class="btn btn-action btn-outline-secondary" onclick="updateKit()">
                                <i class="fas fa-pen me-2"></i>Edit
                            </button>
                            <button class="btn btn-action btn-outline-danger" onclick="deleteKit()">
                                <i class="fas fa-trash-can me-2"></i>Delete
                            </button>

                            <button class="btn btn-action btn-outline-custom" onclick="copyXml()">
                                <i class="fas fa-copy me-2"></i>XML
                            </button>
                            <button id="btnAudit" class="btn btn-action btn-primary-custom" onclick="runSecurityAudit()">
                                <i class="fas fa-shield-virus me-2"></i>Audit
                            </button>
                        </div>
                    </div>
                </div>

                <div class="d-flex justify-content-between align-items-center mb-3">
                    <span class="text-muted small fw-bold text-uppercase ls-1">Dependencies</span>
                    <span id="itemCount" class="badge bg-light text-secondary border">0 items</span>
                </div>

                <div id="depGrid" class="dep-grid">
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="vulnModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold text-danger d-flex align-items-center">
                    <i class="fas fa-triangle-exclamation me-2"></i>Security Alert
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="bg-danger bg-opacity-10 text-danger p-3 rounded-circle">
                        <i class="fas fa-bug fa-xl"></i>
                    </div>
                    <div>
                        <h6 id="modalTitle" class="fw-bold mb-0 font-code text-dark" style="font-size: 1.1rem;"></h6>
                        <span class="badge bg-danger mt-1">Vulnerable</span>
                    </div>
                </div>
                <div class="bg-light p-3 rounded-3 border mb-3">
                    <div id="modalDetail" class="small text-secondary" style="line-height: 1.6;"></div>
                </div>
                <div class="d-flex justify-content-between align-items-center p-3 bg-success-subtle rounded-3 border border-success-subtle">
                    <div class="d-flex align-items-center gap-2 text-success fw-bold">
                        <i class="fas fa-shield-virus"></i> Recommendation
                    </div>
                    <span id="modalFix" class="font-code bg-white px-3 py-1 rounded border border-success-subtle text-dark fw-bold"></span>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light rounded-pill px-4 fw-medium" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<div id="toastContainer" class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 1055;"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const contextPath = "${pageContext.request.contextPath}";
    let currentItems = [];
    let currentKitId = null; // [추가됨] 현재 선택된 Kit ID 저장용
    const vulnModal = new bootstrap.Modal(document.getElementById('vulnModal'));

    function showToast(msg, type='success') {
        const container = document.getElementById('toastContainer');
        const iconClass = type === 'success' ? 'fa-circle-check text-success' : 'fa-circle-exclamation text-danger';
        const el = document.createElement('div');
        el.className = 'toast show align-items-center border-0 shadow-lg rounded-4 mb-2 animate__animated animate__fadeInRight';
        el.innerHTML = `
            <div class="d-flex py-1 px-2">
                <div class="toast-body d-flex align-items-center gap-2">
                    <i class="fas \${iconClass} fa-lg"></i><span class="fw-medium">\${msg}</span>
                </div>
                <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>`;
        container.appendChild(el);
        setTimeout(() => el.remove(), 3500);
    }

    // Kit 상세 불러오기
    function loadKitDetail(kitId, el) {
        currentKitId = kitId;
        // UI 활성화 처리
        document.querySelectorAll('.kit-item').forEach(i => i.classList.remove('active'));
        if(el) el.classList.add('active');

        // 로딩 중 표시 (간단히)
        document.getElementById('emptyState').style.display = 'none';
        const detailArea = document.getElementById('detailArea');
        detailArea.style.display = 'block';
        document.getElementById('depGrid').innerHTML = '<div class="text-center p-5"><span class="spinner-border text-primary"></span></div>';

        fetch(contextPath + '/kits/' + kitId)
            .then(res => res.json())
            .then(data => {
                if (!data) { showToast("데이터를 불러올 수 없습니다.", "error"); return; }

                // 메타데이터 바인딩
                document.getElementById('viewTitle').innerText = data.title || "Untitled Kit";
                document.getElementById('viewDesc').innerText = data.description || "No description provided.";

                // 아이템 목록 바인딩
                currentItems = data.itemList || [];
                renderItems();
            })
            .catch(err => {
                console.error(err);
                showToast("서버 통신 오류", "error");
            });
    }

    function renderItems() {
        const grid = document.getElementById('depGrid');
        document.getElementById('itemCount').innerText = currentItems.length + ' items';
        grid.innerHTML = '';

        if(currentItems.length === 0) {
            grid.innerHTML = '<div class="col-12 text-center text-muted py-4">아이템이 없습니다.</div>';
            return;
        }

        currentItems.forEach((item, idx) => {
            // 초기 상태는 'unknown'으로 간주하거나, 이미 진단된 상태라면 표시
            let statusBadge = '<span class="badge bg-light text-secondary border fw-medium"><i class="fas fa-hourglass-half me-1"></i>Pending</span>';
            let rowClass = '';
            let actionBtn = '';

            if(item.status === 'safe') {
                statusBadge = '<span class="badge bg-success-subtle text-success border border-success-subtle fw-bold"><i class="fas fa-shield-check me-1"></i>Secure</span>';
                rowClass = 'safe';
            } else if(item.status === 'danger') {
                statusBadge = '<span class="badge bg-danger-subtle text-danger border border-danger-subtle fw-bold"><i class="fas fa-bug me-1"></i>Vuln Found</span>';
                rowClass = 'danger';
                actionBtn = `<button class="btn btn-sm btn-outline-danger w-100 fw-bold rounded-pill mt-2" onclick="openModal(\${idx})">Detail</button>`;
            }

            const el = document.createElement('div');
            el.className = `dep-item \${rowClass}`;
            el.innerHTML = `
                <div class="d-flex flex-column" style="overflow:hidden;">
                    <span class="lib-name text-truncate" title="\${item.artifactId}">\${item.artifactId}</span>
                    <span class="lib-group text-truncate" title="\${item.groupId}">\${item.groupId}</span>
                </div>
                <div class="d-flex align-items-center justify-content-between mt-auto pt-2 w-100">
                     <span class="ver-badge">\${item.version}</span>
                     \${statusBadge}
                </div>
                \${actionBtn}
            `;
            grid.appendChild(el);
        });
    }

    // 보안 진단 실행
    async function runSecurityAudit() {
        if(currentItems.length === 0) return;

        const btn = document.getElementById('btnAudit');
        const orgHtml = btn.innerHTML;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Scanning...';
        btn.disabled = true;

        for(let i=0; i<currentItems.length; i++) {
            try {
                const res = await fetch(contextPath + '/api/libraries/check', {
                    method:'POST', headers:{'Content-Type':'application/json'},
                    body: JSON.stringify({
                        groupId: currentItems[i].groupId,
                        artifactId: currentItems[i].artifactId,
                        version: currentItems[i].version
                    })
                });

                if(res.ok) {
                    const data = await res.json();
                    currentItems[i].status = data.safe ? 'safe' : 'danger';
                    if(!data.safe) {
                        currentItems[i].detail = data.detail;
                        currentItems[i].fix = data.fixedVersion;
                    }
                }
            } catch(e) { console.error(e); }
        }
        renderItems();
        btn.innerHTML = orgHtml;
        btn.disabled = false;
        showToast("Audit completed.");
    }

    // 모달 열기
    function openModal(idx) {
        const item = currentItems[idx];
        document.getElementById('modalTitle').innerText = `\${item.artifactId} (\${item.version})`;
        document.getElementById('modalDetail').innerText = item.detail || "상세 정보 없음";
        document.getElementById('modalFix').innerText = item.fix || "정보 없음";
        vulnModal.show();
    }

    // XML 복사
    function copyXml() {
        if(currentItems.length === 0) return;
        let xml = "<dependencies>\n";
        currentItems.forEach(i => {
            xml += `    <dependency>\n        <groupId>\${i.groupId}</groupId>\n        <artifactId>\${i.artifactId}</artifactId>\n        <version>\${i.version}</version>\n    </dependency>\n`;
        });
        xml += "</dependencies>";
        navigator.clipboard.writeText(xml).then(()=>showToast("XML copied to clipboard."));
    }

    function logout() { location.href = contextPath + '/index.jsp'; /* 실제 로그아웃 로직 필요 시 수정 */ }

    // [추가됨] Kit 수정 (간단한 프롬프트 활용)
    function updateKit() {
        if(!currentKitId) {
            showToast("선택된 Kit이 없습니다.", "error");
            return;
        }

        // 현재 화면에 있는 값 가져오기
        const currentTitle = document.getElementById('viewTitle').innerText;
        const currentDesc = document.getElementById('viewDesc').innerText;

        // 수정 입력 받기
        const newTitle = prompt("수정할 제목을 입력하세요:", currentTitle);
        if(newTitle === null) return; // 취소 시 중단

        const newDesc = prompt("수정할 설명을 입력하세요:", currentDesc);
        if(newDesc === null) return;

        // AJAX 요청 (PUT)
        fetch(contextPath + '/kits/' + currentKitId, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                title: newTitle,
                description: newDesc,
                isPublic: true // 기본값 유지
            })
        })
            .then(res => res.text())
            .then(msg => {
                if(msg === 'OK') {
                    alert("수정되었습니다.");
                    location.reload(); // 목록 갱신을 위해 새로고침
                } else {
                    alert("수정 실패: " + msg);
                }
            })
            .catch(err => {
                console.error(err);
                alert("서버 통신 오류");
            });
    }

    // [추가됨] Kit 삭제
    function deleteKit() {
        if(!currentKitId) {
            showToast("선택된 Kit이 없습니다.", "error");
            return;
        }

        if(!confirm("정말로 이 Kit를 삭제하시겠습니까?")) return;

        // AJAX 요청 (DELETE)
        fetch(contextPath + '/kits/' + currentKitId, {
            method: 'DELETE'
        })
            .then(res => res.text())
            .then(msg => {
                if(msg === 'OK') {
                    alert("삭제되었습니다.");
                    location.reload(); // 목록 갱신
                } else {
                    alert("삭제 실패: " + msg);
                }
            })
            .catch(err => {
                console.error(err);
                alert("서버 통신 오류");
            });
    }
</script>
</body>
</html>