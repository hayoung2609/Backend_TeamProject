<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <title>MavenGuard API Test</title>
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 20px; background-color: #f9f9f9; }
    h1 { color: #333; }
    .box { background: white; border: 1px solid #ddd; padding: 20px; margin-bottom: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
    h3 { margin-top: 0; color: #555; }
    button { padding: 10px 20px; cursor: pointer; background: #007bff; color: white; border: none; border-radius: 4px; font-size: 14px; transition: background 0.2s; }
    button:hover { background: #0056b3; }
    pre { background: #2d2d2d; color: #f8f8f2; padding: 15px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; }
    input[type="text"] { padding: 10px; width: 300px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; }

    /* 검색 결과 스타일 */
    .result-list { list-style: none; padding: 0; margin-top: 15px; max-height: 300px; overflow-y: auto; border: 1px solid #eee; }
    .result-item { padding: 10px; border-bottom: 1px solid #eee; background: white; }
    .result-item:last-child { border-bottom: none; }
    .result-item:hover { background-color: #f0f7ff; }
    .artifact-name { font-weight: bold; color: #007bff; font-size: 1.1em; }
    .group-name { color: #666; font-size: 0.9em; }
    .version-badge { background: #28a745; color: white; padding: 2px 6px; border-radius: 10px; font-size: 0.8em; margin-left: 10px; }
  </style>
</head>
<body>
<h1>🛡️ MavenGuard API 통합 테스트</h1>

<!-- 0. 라이브러리 검색 테스트 (NEW) -->
<div class="box">
  <h3>0. 라이브러리 검색 (GET /api/libraries/search)</h3>
  <p>Maven Central에서 실제 라이브러리를 검색합니다.</p>
  <div style="display: flex; gap: 10px;">
    <input type="text" id="keyword" placeholder="검색어 입력 (예: spring-web, mybatis)" onkeypress="if(event.keyCode==13) searchLibraries()"/>
    <button onclick="searchLibraries()">검색 🔍</button>
  </div>
  <div id="searchResult"></div>
</div>

<!-- 1. Kit 저장 테스트 -->
<div class="box">
  <h3>1. Kit 저장 테스트 (POST /api/kits)</h3>
  <p>아래 버튼을 누르면 테스트 데이터('쇼핑몰 프로젝트용 Kit')를 DB에 저장합니다.</p>
  <button onclick="createKit()">Kit 저장하기 💾</button>
  <div id="createResult" style="margin-top: 10px;"></div>
</div>

<!-- 2. 내 Kit 조회 테스트 -->
<div class="box">
  <h3>2. 내 Kit 조회 테스트 (GET /api/kits/my)</h3>
  <p>DB에 저장된 Kit 목록을 JSON 형태로 불러옵니다.</p>
  <button onclick="getMyKits()">목록 불러오기 📂</button>
  <pre id="getResult">결과가 여기에 표시됩니다...</pre>
</div>

<script>
  // 0. 검색 요청 (AJAX)
  function searchLibraries() {
    const keyword = document.getElementById('keyword').value;
    if(!keyword) { alert('검색어를 입력하세요'); return; }

    const resultDiv = document.getElementById('searchResult');
    resultDiv.innerHTML = "<p>검색중...</p>";

    fetch('/api/libraries/search?q=' + encodeURIComponent(keyword))
            .then(response => {
              if (!response.ok) throw new Error("서버 에러 (혹시 컨트롤러 만들었나요?)");
              return response.json();
            })
            .then(json => {
              let html = '<ul class="result-list">';
              if(json.length === 0) {
                html = "<p style='padding:10px; color:red;'>검색 결과가 없습니다.</p>";
              } else {
                json.forEach(lib => {
                  html += '<li class="result-item">' +
                          '<span class="artifact-name">' + lib.artifactId + '</span>' +
                          '<span class="version-badge">' + lib.latestVersion + '</span><br>' +
                          '<span class="group-name">GroupId: ' + lib.groupId + '</span>' +
                          '</li>';
                });
                html += '</ul>';
              }
              resultDiv.innerHTML = html;
            })
            .catch(err => {
              resultDiv.innerHTML = "<p style='color:red; font-weight:bold;'>에러 발생: " + err + "</p>";
            });
  }

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
                      '<p style="color: green; font-weight: bold;">✅ 성공: ' + text + '</p>';
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