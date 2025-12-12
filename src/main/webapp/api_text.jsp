<%--
  Created by IntelliJ IDEA.
  User: kanghayoung
  Date: 2025. 12. 12.
  Time: 오후 11:20
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <title>MavenGuard API Test</title>
  <style>
    body { font-family: sans-serif; padding: 20px; }
    .box { border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; border-radius: 5px; }
    button { padding: 10px 20px; cursor: pointer; background: #007bff; color: white; border: none; border-radius: 4px; }
    button:hover { background: #0056b3; }
    pre { background: #f4f4f4; padding: 10px; border-radius: 4px; }
  </style>
</head>
<body>
<h1>🛡️ MavenGuard API 테스트</h1>

<!-- 1. Kit 저장 테스트 -->
<div class="box">
  <h3>1. Kit 저장 테스트 (POST /api/kits)</h3>
  <p>아래 버튼을 누르면 '쇼핑몰 프로젝트'용 Kit를 저장합니다.</p>
  <button onclick="createKit()">Kit 저장하기</button>
  <div id="createResult"></div>
</div>

<!-- 2. 내 Kit 조회 테스트 -->
<div class="box">
  <h3>2. 내 Kit 조회 테스트 (GET /api/kits/my)</h3>
  <p>저장된 Kit 목록을 불러옵니다.</p>
  <button onclick="getMyKits()">목록 불러오기</button>
  <pre id="getResult"></pre>
</div>

<script>
  // 1. Kit 저장 요청 (AJAX)
  function createKit() {
    const data = {
      "userId": 1,
      "title": "쇼핑몰 프로젝트용 (테스트)",
      "description": "스프링 MVC와 MyBatis를 사용함",
      "isPublic": true,
      "itemList": [
        { "groupId": "org.springframework", "artifactId": "spring-webmvc", "version": "5.3.23" },
        { "groupId": "org.mybatis", "artifactId": "mybatis", "version": "3.5.16" }
      ]
    };

    fetch('/api/kits', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    })
            .then(response => response.text())
            .then(text => {
              document.getElementById('createResult').innerHTML =
                      '<p style="color: green; font-weight: bold;">결과: ' + text + '</p>';
            })
            .catch(err => alert('에러 발생: ' + err));
  }

  // 2. 조회 요청 (AJAX)
  function getMyKits() {
    fetch('/api/kits/my?userId=1')
            .then(response => response.json())
            .then(json => {
              document.getElementById('getResult').innerText = JSON.stringify(json, null, 2);
            })
            .catch(err => alert('에러 발생: ' + err));
  }
</script>
</body>
</html>
