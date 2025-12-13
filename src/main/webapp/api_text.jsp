<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <title>MavenGuard 통합 테스트</title>
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 20px; background-color: #f9f9f9; }
    .box { background: white; border: 1px solid #ddd; padding: 20px; margin-bottom: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
    h3 { margin-top: 0; color: #555; }
    button { padding: 8px 15px; cursor: pointer; background: #007bff; color: white; border: none; border-radius: 4px; }
    button:hover { background: #0056b3; }
    button.secondary { background: #6c757d; }
    button.secondary:hover { background: #5a6268; }
    input[type="text"], textarea { width: 100%; padding: 10px; margin: 5px 0; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    textarea { height: 100px; font-family: monospace; font-size: 12px; }
    .result-area { background: #2d2d2d; color: #f8f8f2; padding: 15px; border-radius: 4px; margin-top: 10px; min-height: 50px; font-family: monospace; }
    .safe { color: #28a745; font-weight: bold; }
    .danger { color: #dc3545; font-weight: bold; }
    ul { padding-left: 20px; margin: 0; }
    li { margin-bottom: 5px; }
  </style>
</head>
<body>
<h1>🛡️ MavenGuard 기능별 테스트</h1>

<!-- 1. 라이브러리 검색 (NEW) -->
<div class="box">
  <h3>🔍 1. 라이브러리 검색 (Maven Central API)</h3>
  <p>키워드로 Maven Central의 라이브러리를 검색합니다. (백엔드에서 외부 API 호출)</p>
  <div style="display: flex; gap: 10px;">
    <input type="text" id="searchKeyword" placeholder="검색어 입력 (예: spring-boot, mybatis)" onkeypress="if(event.keyCode==13) searchLib()"/>
    <button onclick="searchLib()">검색</button>
  </div>
  <div id="searchResult" class="result-area">결과 대기 중...</div>
</div>

<!-- 2. pom.xml 파싱 -->
<div class="box">
  <h3>📝 2. pom.xml 붙여넣기 분석</h3>
  <p>pom.xml의 &lt;dependencies&gt; 부분을 붙여넣으세요.</p>
  <textarea id="pomInput" placeholder="<dependency>...</dependency> 태그들을 붙여넣으세요."></textarea>
  <button onclick="parsePom()">분석하기</button>
  <div id="parseResult" class="result-area">결과 대기 중...</div>
</div>

<!-- 3. Kit 저장 -->
<div class="box">
  <h3>💾 3. Kit 저장 (DB)</h3>
  <button onclick="createKit()">테스트 데이터 저장</button>
  <div id="dbResult" class="result-area">결과 대기 중...</div>
</div>

<!-- 4. 보안 진단 (개별 테스트) -->
<div class="box">
  <h3>🧪 4. 보안 진단 단위 테스트 (OSV API)</h3>
  <p>특정 버전의 취약점을 수동으로 검사합니다. (예: log4j-core 2.14.1)</p>
  <input type="text" id="secGroup" placeholder="GroupId" value="org.apache.logging.log4j">
  <input type="text" id="secArtifact" placeholder="ArtifactId" value="log4j-core">
  <input type="text" id="secVersion" placeholder="Version" value="2.14.1">
  <button class="secondary" onclick="checkSecurity()">진단 실행</button>
  <div id="secResult" class="result-area">결과 대기 중...</div>
</div>

<script>
  // Context Path 자동 감지 (JSP가 아니어도 작동하도록 JS로 처리)
  // 예: http://localhost:8080/MavenGuard/api/... -> /MavenGuard
  const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/", 1));
  // 만약 루트 경로(/)에 배포된 경우 빈 문자열 처리
  const apiBase = (contextPath === "/api_text.jsp" || contextPath === "") ? "" : contextPath;

  console.log("API Base URL:", apiBase); // 디버깅용

  // 1. 검색 기능
  function searchLib() {
    const q = document.getElementById('searchKeyword').value;
    if(!q) return alert("검색어를 입력하세요");

    document.getElementById('searchResult').innerText = "검색중...";

    // 수정된 부분: apiBase + 경로
    fetch(apiBase + '/api/libraries/search?q=' + encodeURIComponent(q))
            .then(res => {
              // 응답이 HTML(에러페이지)인지 확인
              const contentType = res.headers.get("content-type");
              if (contentType && contentType.indexOf("application/json") === -1) {
                return res.text().then(text => { throw new Error("서버 에러 (HTML 응답): " + text.substring(0, 100) + "..."); });
              }
              if (!res.ok) throw new Error("HTTP 오류: " + res.status);
              return res.json();
            })
            .then(data => {
              const resultDiv = document.getElementById('searchResult');
              if(data.length === 0) {
                resultDiv.innerHTML = "검색 결과가 없습니다.";
                return;
              }
              let html = "<ul>";
              data.forEach(item => {
                html += "<li><b>" + item.artifactId + "</b> <small>(" + item.groupId + ")</small> - <span style='color:#4caf50'>" + item.latestVersion + "</span></li>";
              });
              html += "</ul>";
              resultDiv.innerHTML = html;
            })
            .catch(err => {
              document.getElementById('searchResult').innerHTML = "<span style='color:red'>" + err + "</span>";
              console.error(err);
            });
  }

  // 2. 파싱 기능
  function parsePom() {
    const xml = document.getElementById('pomInput').value;
    // 수정된 부분: apiBase + 경로
    fetch(apiBase + '/api/libraries/parse', {
      method: 'POST',
      headers: { 'Content-Type': 'text/plain' },
      body: xml
    })
            .then(res => res.json())
            .then(json => {
              document.getElementById('parseResult').innerText = JSON.stringify(json, null, 2);
            })
            .catch(err => alert("파싱 실패: " + err));
  }

  // 3. 저장 기능
  function createKit() {
    const data = {
      "userId": 1,
      "title": "자동 저장 Kit",
      "description": "테스트",
      "isPublic": true,
      "itemList": [
        { "groupId": "org.springframework", "artifactId": "spring-webmvc", "version": "5.3.23" }
      ]
    };
    // 수정된 부분: apiBase + 경로
    fetch(apiBase + '/api/kits', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(data)
    })
            .then(res => res.text())
            .then(text => document.getElementById('dbResult').innerText = text)
            .catch(err => alert("저장 실패: " + err));
  }

  // 4. 보안 진단
  function checkSecurity() {
    const data = {
      groupId: document.getElementById('secGroup').value,
      artifactId: document.getElementById('secArtifact').value,
      version: document.getElementById('secVersion').value
    };

    document.getElementById('secResult').innerText = "진단 중...";

    // 수정된 부분: apiBase + 경로
    fetch(apiBase + '/api/libraries/check', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    })
            .then(res => res.json())
            .then(json => {
              const resultDiv = document.getElementById('secResult');
              if(json.safe) {
                resultDiv.innerHTML = "<span class='safe'>[안전]</span> " + json.message;
              } else {
                resultDiv.innerHTML = "<span class='danger'>[위험!]</span> 취약점 발견: " + json.count + "개<br>내용: " + json.detail;
              }
            })
            .catch(err => alert("진단 실패: " + err));
  }
</script>
</body>
</html>