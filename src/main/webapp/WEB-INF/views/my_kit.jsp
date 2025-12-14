<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MavenGuard - 나만의 Kit</title>

    <!-- Bootstrap / FontAwesome -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        body { background-color: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
        .kit-card { cursor: pointer; transition: 0.2s; }
        .kit-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .item-row { border-bottom: 1px solid #eee; padding: 10px 0; }
        .item-row:last-child { border-bottom: none; }
        .badge-lib { background: #eef2ff; color: #4338ca; }
    </style>
</head>

<body>

<!-- 상단 네비게이션 -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold" href="/index.jsp">
            <i class="fas fa-shield-alt"></i> MavenGuard
        </a>
        <ul class="navbar-nav ms-auto">
            <li class="nav-item">
                <a class="nav-link active" href="/kits/my">나만의 Kit</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="/index.jsp">메인으로</a>
            </li>
        </ul>
    </div>
</nav>

<div class="container py-5">

    <h3 class="fw-bold mb-4">
        <i class="fas fa-layer-group text-success"></i> 나만의 Kit 보관함
    </h3>

    <div class="row">
        <!-- 왼쪽: Kit 목록 -->
        <div class="col-md-4">
            <div class="card mb-3">
                <div class="card-header fw-bold bg-white">
                    저장된 Kit
                </div>

                <div class="list-group list-group-flush" id="kitList">
                    <c:forEach var="kit" items="${kitList}">
                        <a class="list-group-item list-group-item-action kit-card"
                           onclick="loadKitDetail(${kit.kitId})">
                            <div class="fw-bold">${kit.title}</div>
                            <small class="text-muted">
                                <i class="fas fa-clock"></i>
                                    ${kit.createdAt}
                            </small>
                        </a>
                    </c:forEach>

                    <c:if test="${empty kitList}">
                        <div class="text-center text-muted p-4">
                            저장된 Kit이 없습니다.
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

        <!-- 오른쪽: Kit 상세 -->
        <div class="col-md-8">
            <div class="card">
                <div class="card-header fw-bold bg-white">
                    <i class="fas fa-box-open"></i> Kit 상세 내용
                </div>

                <div class="card-body" id="kitDetail">
                    <div class="text-center text-muted py-5">
                        <i class="fas fa-mouse-pointer fa-2x mb-3"></i>
                        <p>왼쪽에서 Kit을 선택하세요</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Script -->
<script>
    function loadKitDetail(kitId) {
        fetch('/kits/' + kitId)
            .then(res => res.json())
            .then(data => {
                if (!data || !data.itemList) {
                    alert("Kit 정보를 불러올 수 없습니다.");
                    return;
                }

                let html = '';
                data.itemList.forEach(item => {
                    html += `
                        <div class="item-row d-flex justify-content-between align-items-center">
                            <div>
                                <div class="fw-bold">\${item.artifactId}</div>
                                <small class="text-muted">\${item.groupId}</small>
                            </div>
                            <span class="badge badge-lib">\${item.version}</span>
                        </div>
                    `;
                });

                document.getElementById('kitDetail').innerHTML = html;
            })
            .catch(err => {
                console.error(err);
                alert("서버 오류");
            });
    }
</script>

</body>
</html>


