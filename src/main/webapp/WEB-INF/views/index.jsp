<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MavenGuard - Security Audit</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">

    <style>
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
        .navbar { background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(10px); border-bottom: 1px solid var(--border-color); padding: 1rem 0; }
        .brand-logo { font-family: var(--font-code); font-weight: 700; font-size: 1.35rem; color: var(--primary-dark); letter-spacing: -0.03em; display: flex; align-items: center; gap: 10px; }
        .user-pill { background: #f8fafc; border: 1px solid var(--border-color); padding: 6px 16px; border-radius: 999px; font-size: 0.9rem; font-weight: 500; transition: all 0.2s; }
        .user-pill:hover { border-color: var(--primary-accent); color: var(--primary-accent); }
        .hero-section { text-align: center; padding: 4rem 0 3rem; }
        .hero-badge { background: #eff6ff; color: var(--primary-accent); padding: 6px 12px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; font-family: var(--font-code); margin-bottom: 1rem; display: inline-block; border: 1px solid #dbeafe; }
        .hero-title { font-weight: 800; color: var(--primary-dark); letter-spacing: -0.03em; margin-bottom: 1rem; }
        .hero-desc { color: var(--text-sub); font-size: 1.1rem; max-width: 580px; margin: 0 auto; line-height: 1.6; }
        .hero-desc code { background: #e2e8f0; color: var(--primary-dark); padding: 2px 6px; border-radius: 4px; font-family: var(--font-code); }
        .main-card { background: var(--surface-color); border-radius: 20px; box-shadow: var(--shadow-soft); border: 1px solid var(--border-color); overflow: visible; transition: transform 0.3s, box-shadow 0.3s; }
        .main-card:focus-within { box-shadow: var(--shadow-glow), var(--shadow-soft); border-color: #bfdbfe; }
        .nav-tabs { border-bottom: 1px solid var(--border-color); padding: 0 1.5rem; background: #f8fafc; gap: 1rem; border-radius: 20px 20px 0 0; }
        .nav-tabs .nav-link { border: none; color: var(--text-sub); font-weight: 600; padding: 1.2rem 1rem; background: transparent; position: relative; }
        .nav-tabs .nav-link:hover { color: var(--primary-dark); }
        .nav-tabs .nav-link.active { color: var(--primary-accent); background: transparent; }
        .nav-tabs .nav-link.active::after { content: ''; position: absolute; bottom: 0; left: 0; width: 100%; height: 3px; background: var(--primary-accent); border-radius: 3px 3px 0 0; }
        .search-area { padding: 2rem; }
        .form-control-custom { border: 2px solid #e2e8f0; border-radius: 12px; padding: 1rem 1.25rem; font-size: 1.05rem; transition: all 0.2s; }
        .form-control-custom:focus { border-color: var(--primary-accent); box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1); }
        #searchResult { position: absolute; top: 100%; left: 0; right: 0; background: white; border: 1px solid var(--border-color); border-radius: 12px; margin-top: 8px; box-shadow: 0 20px 30px -5px rgba(0, 0, 0, 0.15); max-height: 350px; overflow-y: auto; z-index: 1000; }
        .result-item { padding: 16px 20px; border-bottom: 1px solid #f1f5f9; cursor: pointer; transition: 0.15s; }
        .result-item:hover { background-color: #f8fafc; padding-left: 24px; }
        .result-item:last-child { border-bottom: none; }
        .workspace-title { font-family: var(--font-code); font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-sub); margin-bottom: 1rem; display: flex; justify-content: space-between; align-items: flex-end; }

        /* Grid Layout */
        #tagContainer {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 16px;
            padding-bottom: 100px;
        }

        .dep-item {
            background: white; border: 1px solid var(--border-color); border-radius: 12px; padding: 1.25rem;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex; flex-direction: column;
            gap: 12px;
            position: relative; overflow: hidden;
        }
        .dep-item:hover { transform: translateY(-4px); box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1); border-color: #cbd5e1; }
        .dep-item::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: #cbd5e1; transition: 0.3s; }
        .dep-item.safe::before { background: var(--success-color); }
        .dep-item.safe { background: linear-gradient(to right, var(--success-bg), white 30%); border-color: #bbf7d0; }
        .dep-item.danger::before { background: var(--danger-color); }
        .dep-item.danger { background: linear-gradient(to right, var(--danger-bg), white 30%); border-color: #fecaca; }
        .lib-name { font-family: var(--font-code); font-weight: 700; color: var(--primary-dark); font-size: 1.05rem; word-break: break-all; }
        .lib-group { font-size: 0.85rem; color: var(--text-sub); }
        .ver-badge { font-family: var(--font-code); background: #f1f5f9; color: var(--text-main); padding: 4px 10px; border-radius: 6px; font-size: 0.85rem; border: 1px solid #e2e8f0; cursor: pointer; transition: 0.2s; }
        .ver-badge:hover { border-color: var(--primary-accent); color: var(--primary-accent); background: white; }

        /* Floating Action Bar */
        .floating-action-bar {
            position: fixed;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            width: 90%;
            max-width: 800px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(12px);
            padding: 12px 12px 12px 24px;
            border-radius: 100px;
            box-shadow: 0 20px 50px -10px rgba(0, 0, 0, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.5);
            display: flex;
            justify-content: space-between;
            align-items: center;
            z-index: 1040;
            animation: slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        }
        @keyframes slideUp { from { transform: translate(-50%, 150%); opacity: 0; } to { transform: translate(-50%, 0); opacity: 1; } }

        .btn-check-main {
            background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
            border: none; padding: 12px 28px; font-weight: 700; font-size: 1rem; border-radius: 99px;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.25); transition: all 0.3s;
            color: white;
            white-space: nowrap;
        }
        .btn-check-main:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(37, 99, 235, 0.35); }
        .btn-check-main:disabled { opacity: 0.7; cursor: wait; transform: none; }

        .modal-content { border: none; border-radius: 24px; box-shadow: 0 20px 50px -12px rgba(0, 0, 0, 0.25); }
        .modal-header { border-bottom: 1px solid #f1f5f9; padding: 1.5rem; }
        .modal-body { padding: 1.5rem; }
        .modal-footer { border-top: none; padding: 0 1.5rem 1.5rem; }
        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
    </style>
</head>
<body>

<nav class="navbar sticky-top">
    <div class="container">
        <a class="navbar-brand brand-logo" href="${pageContext.request.contextPath}/">
            <span class="fa-stack" style="font-size: 0.8em;">
              <i class="fas fa-circle fa-stack-2x" style="color: rgba(59, 130, 246, 0.1);"></i>
              <i class="fas fa-shield-halved fa-stack-1x text-primary"></i>
            </span>
            MavenGuard
        </a>
        <div class="d-flex align-items-center gap-3">
            <c:if test="${empty sessionScope.loginUser}">
                <a href="${pageContext.request.contextPath}/login" class="btn btn-dark rounded-pill px-4 fw-medium text-sm">Sign In</a>
            </c:if>
            <c:if test="${not empty sessionScope.loginUser}">

                <c:if test="${sessionScope.loginUser.role == 'ROLE_ADMIN'}">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-danger rounded-pill border fw-bold text-white me-2 shadow-sm">
                        <i class="fas fa-user-shield me-1"></i>Admin
                    </a>
                </c:if>

                <a class="btn btn-light rounded-pill border fw-medium text-secondary me-2" href="${pageContext.request.contextPath}/kits/my">
                    <i class="fas fa-box-archive me-2 text-primary"></i>My Kit
                </a>

                <div class="dropdown">
                </div>
            </c:if>
        </div>
    </div>
</nav>

<div class="container pb-5" style="max-width: 900px;"> <div class="hero-section">
    <span class="hero-badge"><i class="fas fa-check-double me-1"></i> Dependency Auditor</span>
    <h1 class="hero-title display-5">Secure Your Build Pipeline</h1>
    <p class="hero-desc">
        <code>pom.xml</code>의 의존성을 스캔하여 알려진 취약점(CVE)을 탐지합니다.<br>
        프로젝트가 안전한 최신 라이브러리를 사용하고 있는지 지금 확인하세요.
    </p>
</div>

    <div class="main-card mb-5">
        <ul class="nav nav-tabs" id="inputTab" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="search-tab" data-bs-toggle="tab" data-bs-target="#search-panel" type="button">
                    <i class="fas fa-magnifying-glass me-2"></i>Library Search
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="paste-tab" data-bs-toggle="tab" data-bs-target="#paste-panel" type="button">
                    <i class="fas fa-code me-2"></i>XML Paste
                </button>
            </li>
        </ul>

        <div class="tab-content">
            <div class="tab-pane fade show active" id="search-panel">
                <div class="search-area position-relative">
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0 ps-3" style="border-radius: 12px 0 0 12px; border: 2px solid #e2e8f0; border-right: none;">
                            <i class="fas fa-search text-muted"></i>
                        </span>
                        <input type="text" id="keyword" class="form-control form-control-custom border-start-0"
                               style="border-radius: 0 12px 12px 0;"
                               placeholder="Search artifacts (e.g. spring-boot-starter-web)..." autocomplete="off">
                    </div>
                    <div id="searchResult" class="animate__animated animate__fadeIn" style="display:none;"></div>
                </div>
            </div>

            <div class="tab-pane fade" id="paste-panel">
                <div class="p-4">
                    <div class="position-relative">
                        <textarea id="pomArea" class="form-control font-code bg-light border-0 mb-3 p-3" rows="6"
                                  placeholder="<dependencies>...</dependencies>" style="font-size: 0.9rem; resize: none;"></textarea>
                        <div class="position-absolute top-0 end-0 p-2">
                            <span class="badge bg-secondary opacity-50">XML</span>
                        </div>
                    </div>
                    <button class="btn btn-dark w-100 py-2.5 rounded-3 fw-bold" onclick="parsePom()">
                        <i class="fas fa-file-import me-2"></i>Analyze XML
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div id="workspace" style="display:none;">
        <div class="workspace-title">
            <span><i class="fas fa-list-ul me-2 text-primary"></i>Audit Target List</span>
            <button class="btn btn-link text-decoration-none text-muted p-0" style="font-size: 0.85rem;"
                    onclick="items=[]; render(); showToast('List cleared.', 'trash');">
                Clear All
            </button>
        </div>

        <div id="tagContainer">
        </div>

        <div class="floating-action-bar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-light rounded-pill border fw-medium text-secondary" onclick="copyXml()">
                    <i class="fas fa-copy me-2"></i>XML
                </button>
                <div class="text-muted small border-start ps-3" style="line-height: 1.2;">
                    Ready to scan<br>
                    <span id="itemCountBadge" class="fw-bold text-dark">0 items</span>
                </div>
            </div>

            <div class="d-flex gap-2">
                <c:if test="${not empty sessionScope.loginUser}">
                    <button class="btn btn-dark rounded-pill px-4 fw-bold shadow-sm" onclick="saveKit()">
                        <i class="fas fa-cloud-arrow-up me-2"></i>Save Kit
                    </button>
                </c:if>

                <button id="btnCheck" class="btn-check-main" onclick="runSecurityCheck()">
                    <i class="fas fa-shield-virus me-2"></i>Run Audit
                </button>
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
                    <button id="btnFix" class="btn btn-success rounded-pill px-4 fw-bold shadow-sm">
                        <i class="fas fa-wrench me-2"></i>Apply Fix
                    </button>
                </div>
            </div>
        </div>
    </div>
    <div id="toastContainer" class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 1055;"></div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const contextPath = "${pageContext.request.contextPath}";
        let items = [];
        const vulnModal = new bootstrap.Modal(document.getElementById('vulnModal'));
        let selectedIndex = -1;

        function formatDate(timestamp) {
            if(!timestamp) return '';
            const date = new Date(timestamp);
            return date.toLocaleDateString();
        }

        function showToast(msg, type='success') {
            const container = document.getElementById('toastContainer');
            const iconClass = type === 'success' ? 'fa-circle-check text-success' :
                type === 'trash' ? 'fa-trash-can text-secondary' : 'fa-circle-exclamation text-danger';

            const el = document.createElement('div');
            el.className = 'toast show align-items-center border-0 shadow-lg rounded-4 mb-2 animate__animated animate__fadeInRight';
            el.innerHTML = `
            <div class="d-flex py-1 px-2">
                <div class="toast-body d-flex align-items-center gap-2">
                    <i class="fas \${iconClass} fa-lg"></i>
                    <span class="fw-medium">\${msg}</span>
                </div>
                <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>`;
            container.appendChild(el);
            setTimeout(() => { el.remove(); }, 3500);
        }

        // --- Search Logic ---
        let timer;
        const searchInput = document.getElementById('keyword');
        const resDiv = document.getElementById('searchResult');

        searchInput.addEventListener('input', function() {
            clearTimeout(timer);
            timer = setTimeout(() => {
                const q = this.value.trim();
                if(!q) { resDiv.style.display='none'; return; }

                fetch(contextPath + '/api/libraries/search?q=' + encodeURIComponent(q))
                    .then(res => res.json())
                    .then(renderSearchResults)
                    .catch(err => console.error(err));
            }, 300);
        });

        document.addEventListener('click', (e) => {
            if (!searchInput.contains(e.target) && !resDiv.contains(e.target)) resDiv.style.display = 'none';
        });

        function renderSearchResults(data) {
            resDiv.innerHTML = '';
            if(!data || data.length === 0) return;
            resDiv.style.display = 'block';

            data.forEach(item => {
                const el = document.createElement('div');
                el.className = 'result-item';
                const descHtml = item.description ?
                    `<span class="badge bg-secondary bg-opacity-10 text-secondary border ms-2" style="font-size:0.7em">\${item.description}</span>` : '';

                el.innerHTML = `
                <div class="d-flex justify-content-between align-items-center">
                    <div style="flex: 1; min-width: 0;">
                        <div class="d-flex align-items-center flex-wrap gap-1">
                            <span class="fw-bold text-dark font-code fs-6">\${item.artifactId}</span>
                            <span class="badge bg-primary bg-opacity-10 text-primary border border-primary-subtle font-code">\${item.latestVersion}</span>
                        </div>
                        <div class="mt-1 text-truncate">
                            <span class="text-secondary font-code small">\${item.groupId}</span>
                            \${descHtml}
                        </div>
                        <div class="text-muted small mt-1" style="font-size: 0.75rem;">
                             <i class="far fa-clock me-1"></i>Updated: \${formatDate(item.lastUpdated)}
                        </div>
                    </div>
                    <div class="ms-3 text-end">
                        <i class="fas fa-plus-circle text-primary opacity-50 fa-lg"></i>
                    </div>
                </div>`;
                el.onclick = () => {
                    addItem(item.groupId, item.artifactId, item.latestVersion);
                    resDiv.style.display = 'none';
                    searchInput.value = '';
                };
                resDiv.appendChild(el);
            });
        }

        function parsePom() {
            const xml = document.getElementById('pomArea').value;
            if(!xml.trim()) return showToast("Please paste XML content.", "error");

            fetch(contextPath + '/api/libraries/parse', {
                method: 'POST', headers: {'Content-Type': 'text/plain'}, body: xml
            })
                .then(res => res.json())
                .then(data => {
                    let count = 0;
                    data.forEach(item => {
                        if(!items.some(i => i.g === item.groupId && i.a === item.artifactId)) {
                            items.push({ g: item.groupId, a: item.artifactId, v: item.latestVersion, status: 'unknown' });
                            count++;
                        }
                    });
                    render();
                    document.getElementById('pomArea').value = '';
                    showToast(`Analyzed \${count} dependencies.`);
                    document.getElementById('search-tab').click();
                })
                .catch(() => showToast("Parsing failed.", "error"));
        }

        function addItem(g, a, v) {
            if(items.some(i => i.g === g && i.a === a)) {
                showToast("Already exists in list.", "error");
                return;
            }
            items.push({ g: g, a: a, v: v, status: 'unknown' });
            render();
            showToast("Library added. Don't forget to Audit!");
        }

        function render() {
            const container = document.getElementById('tagContainer');
            const workspace = document.getElementById('workspace');

            document.getElementById('itemCountBadge').innerText = items.length + ' items';

            if(items.length > 0) {
                workspace.style.display = 'block';
                if(container.innerHTML === '') workspace.scrollIntoView({ behavior: 'smooth' });
            } else {
                workspace.style.display = 'none';
                return;
            }

            container.innerHTML = '';
            items.forEach((item, idx) => {
                let statusBadge = '<span class="badge bg-light text-secondary border fw-medium"><i class="fas fa-hourglass-half me-1"></i>Pending</span>';
                let rowClass = '';
                let actionBtn = '';

                if(item.status === 'safe') {
                    statusBadge = '<span class="badge bg-success-subtle text-success border border-success-subtle fw-bold"><i class="fas fa-shield-check me-1"></i>Secure</span>';
                    rowClass = 'safe';
                } else if(item.status === 'danger') {
                    statusBadge = '<span class="badge bg-danger-subtle text-danger border border-danger-subtle fw-bold"><i class="fas fa-bug me-1"></i>Vuln Found</span>';
                    rowClass = 'danger';
                    actionBtn = `<button class="btn btn-sm btn-outline-danger w-100 fw-bold rounded-pill" onclick="openModal(\${idx})">Fix It</button>`;
                }

                const el = document.createElement('div');
                el.className = `dep-item \${rowClass}`;
                el.innerHTML = `
                <div class="d-flex justify-content-between align-items-start w-100">
                    <div class="d-flex flex-column" style="overflow:hidden;">
                        <span class="lib-name text-truncate">\${item.a}</span>
                        <span class="lib-group text-truncate">\${item.g}</span>
                    </div>
                    <button class="btn btn-link text-secondary p-0 ms-2 hover-danger" onclick="removeItem(\${idx})" title="Remove">
                        <i class="fas fa-xmark"></i>
                    </button>
                </div>

                <div class="d-flex align-items-center justify-content-between mt-auto pt-2 w-100">
                     <span class="ver-badge" onclick="editVersion(\${idx})" title="Edit Version">\${item.v}</span>
                     \${statusBadge}
                </div>

                \${actionBtn ? '<div class="mt-2 w-100">' + actionBtn + '</div>' : ''}
            `;
                container.appendChild(el);
            });
        }

        function removeItem(idx) { items.splice(idx, 1); render(); }

        function editVersion(idx) {
            const newVer = prompt("Enter manual version:", items[idx].v);
            if(newVer && newVer.trim() && newVer !== items[idx].v) {
                items[idx].v = newVer.trim(); items[idx].status = 'unknown'; render();
            }
        }

        async function runSecurityCheck() {
            const btn = document.getElementById('btnCheck');
            const orgHtml = btn.innerHTML;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Scanning...';
            btn.disabled = true;

            await new Promise(r => setTimeout(r, 600));

            for(let i=0; i<items.length; i++) {
                try {
                    const res = await fetch(contextPath + '/api/libraries/check', {
                        method:'POST', headers:{'Content-Type':'application/json'},
                        body: JSON.stringify({groupId: items[i].g, artifactId: items[i].a, version: items[i].v})
                    });

                    if(res.ok) {
                        const data = await res.json();
                        items[i].status = data.safe ? 'safe' : 'danger';
                        if(!data.safe) {
                            items[i].detail = data.detail;
                            items[i].fix = data.fixedVersion;
                        }
                    }
                } catch(e) { console.error(e); }
            }
            render();
            btn.innerHTML = orgHtml;
            btn.disabled = false;
            showToast("Security audit completed.");
        }

        function openModal(idx) {
            selectedIndex = idx;
            const item = items[idx];
            document.getElementById('modalTitle').innerText = `\${item.a} (\${item.v})`;
            document.getElementById('modalDetail').innerText = item.detail || "No detailed CVE info available.";

            const fixVer = item.fix;
            const btn = document.getElementById('btnFix');
            const fixSpan = document.getElementById('modalFix');

            if(fixVer && fixVer !== '정보 없음' && fixVer !== 'Unknown') {
                fixSpan.innerText = fixVer;
                btn.disabled = false;
                btn.onclick = () => {
                    items[idx].v = fixVer;
                    items[idx].status = 'safe';
                    items[idx].detail = null;
                    render();
                    vulnModal.hide();
                    showToast("Updated to safe version (" + fixVer + ").");
                };
            } else {
                fixSpan.innerText = "Manual fix required";
                btn.disabled = true;
            }
            vulnModal.show();
        }

        function saveKit() {
            if ("${sessionScope.loginUser}" === "") {
                alert("로그인이 필요한 서비스입니다.");
                location.href = contextPath + "/login";
                return;
            }

            if (items.length === 0) {
                showToast("저장할 라이브러리가 없습니다.", "error");
                return;
            }

            const title = prompt("Kit 제목을 입력하세요:", "My Awesome Stack");
            if (title === null) return;

            const desc = prompt("설명을 입력하세요:", "프로젝트 설명을 입력하세요.");
            if (desc === null) return;

            const kitItems = items.map(i => ({
                groupId: i.g,
                artifactId: i.a,
                version: i.v
            }));

            fetch(contextPath + '/kits', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    title: title,
                    description: desc,
                    projectVersion: "1.0.0",
                    category: "General",
                    isPublic: true,
                    itemList: kitItems
                })
            })
                .then(res => res.text())
                .then(msg => {
                    if (msg === 'OK') {
                        alert("Kit이 저장되었습니다! \nMy Kits 페이지에서 확인하세요.");
                        items = [];
                        render();
                    } else if (msg === 'LOGIN_REQUIRED') {
                        alert("로그인이 필요합니다.");
                        location.href = contextPath + "/login";
                    } else {
                        alert("저장 실패: " + msg);
                    }
                })
                .catch(err => {
                    console.error(err);
                    alert("서버 오류 발생");
                });
        }

        function copyXml() {
            if(items.length===0) return;
            let xml = "<dependencies>\n";
            items.forEach(i => xml += `    <dependency>\n        <groupId>\${i.g}</groupId>\n        <artifactId>\${i.a}</artifactId>\n        <version>\${i.v}</version>\n    </dependency>\n`);
            xml += "</dependencies>";
            navigator.clipboard.writeText(xml).then(()=>showToast("XML copied to clipboard."));
        }

        // [수정] 로그아웃 로직: 서버 호출 후 메인으로 리다이렉트
        function logout() {
            fetch(contextPath + '/api/auth/logout', {
                method: 'POST'
            }).then(() => {
                location.href = contextPath + '/';
            }).catch(err => {
                console.error(err);
                location.href = contextPath + '/';
            });
        }
    </script>
</body>
</html>