<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>나만의 Kit</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .kit-box { cursor: pointer; }
        .kit-box:hover { background: #f8f9fa; }
    </style>
</head>
<body>

<nav class="navbar navbar-dark bg-dark px-4">
    <a class="navbar-brand" href="${pageContext.request.contextPath}/index.jsp">MavenGuard</a>
    <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/index.jsp">메인으로</a>
</nav>

<div class="container mt-4">
    <div class="row">
        <!-- 왼쪽: Kit 목록 -->
        <div class="col-md-4">
            <h5>📦 저장된 Kit</h5>
            <div class="list-group">
                <c:if test="${empty kitList}">
                    <div class="list-group-item text-muted">저장된 Kit이 없습니다.</div>
                </c:if>

                <c:forEach var="kit" items="${kitList}">
                    <div class="list-group-item kit-box"
                         onclick="loadKit(${kit.kitId})">
                        <strong>${kit.title}</strong><br>
                        <small class="text-muted">${kit.createdAt}</small>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- 오른쪽: Kit 상세 -->
        <div class="col-md-8">
            <h5>📄 Kit 상세</h5>
            <div id="detailBox" class="border rounded p-4 text-muted text-center">
                왼쪽에서 Kit을 선택하세요
            </div>
        </div>
    </div>
</div>

<script>
    const contextPath = "${pageContext.request.contextPath}";

    function loadKit(kitId) {
        fetch(contextPath + "/kits/" + kitId)
            .then(res => res.json())
            .then(data => {
                if (!data || !data.itemList) return;

                let html = `<h6>${data.title}</h6><ul class="list-group">`;
                data.itemList.forEach(item => {
                    html += `
                    <li class="list-group-item">
                        <b>${item.artifactId}</b><br>
                        <small>${item.groupId} : ${item.version}</small>
                    </li>`;
                });
                html += "</ul>";

                document.getElementById("detailBox").innerHTML = html;
            });
    }
</script>

</body>
</html>


