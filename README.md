# MavenGuard



**MavenGuard**는 Java Maven 프로젝트의 의존성(Dependency) 보안 취약점을 진단하고, 자주 사용하는 라이브러리 조합을 Kit 형태로 관리할 수 있는 웹 서비스입니다.



Google OSV API와 Maven Central 검색을 연동하여, 개발자가 `pom.xml` 작성 단계에서부터 안전한 라이브러리 버전을 선택할 수 있도록 돕습니다.



## 주요 기능



### 1. 라이브러리 보안 진단 (Security Audit)



* **Maven Central 검색:** 외부 API를 연동하여 실시간으로 라이브러리를 검색할 수 있습니다.

* **XML 파싱 진단:** 사용 중인 `pom.xml`의 `<dependencies>` 부분을 붙여넣으면 자동으로 파싱하여 목록화합니다.

* **취약점(CVE) 스캔:** Google OSV API를 활용하여 각 라이브러리 버전의 알려진 보안 취약점을 검사합니다.

* **해결책 제공:** 취약점이 발견된 경우, 안전한 패치 버전(Fixed Version)과 권장 사항을 제공합니다.



### 2. Kit 관리 (Dependency Management)



* **나만의 Kit 저장:** 자주 사용하는 라이브러리 목록을 하나의 Kit로 묶어 저장할 수 있습니다.

* **CRUD 기능:** 저장된 Kit의 목록 조회, 상세 보기, 수정, 삭제가 가능합니다.

* **XML 변환:** 저장된 Kit를 언제든지 다시 `pom.xml` 형식의 XML 텍스트로 복사할 수 있습니다.



### 3. 회원 및 관리자 기능



* **회원가입/로그인:** BCrypt 암호화를 적용한 안전한 회원가입 및 로그인 기능을 제공합니다.

* **관리자 대시보드:** 관리자(Admin) 권한을 가진 사용자는 전체 회원 관리(권한 수정, 강제 탈퇴) 및 전체 Kit 관리가 가능합니다.



## 기술 스택 (Tech Stack)



### Backend



* **Language:** Java 8+

* **Framework:** Spring Framework (Spring MVC)

* **Database:** MariaDB (JDBC)

* **ORM:** MyBatis (Mapper XML)

* **Connection Pool:** HikariCP

* **Build Tool:** Maven



### Frontend



* **View Engine:** JSP (JavaServer Pages), JSTL

* **CSS Framework:** Bootstrap 5

* **Communication:** Fetch API (AJAX)



### External APIs



* **Maven Central Search:** 라이브러리 검색

* **Google OSV (Open Source Vulnerability):** 보안 취약점 데이터베이스



## 설치 및 실행 방법 (Getting Started)



### 1. 프로젝트 클론



```bash

git clone https://github.com/your-repo/MavenGuard.git

cd MavenGuard



```



### 2. 데이터베이스 설정



`src/main/webapp/WEB-INF/spring/root-context.xml` 파일에서 DB 연결 정보를 본인의 환경에 맞게 수정해야 합니다.



```xml

<bean id="dataSource" class="com.zaxxer.hikari.HikariDataSource" destroy-method="close">

    <property name="driverClassName" value="org.mariadb.jdbc.Driver" />

    <property name="jdbcUrl" value="jdbc:mariadb://localhost:3306/YOUR_DB_NAME" />

    <property name="username" value="YOUR_DB_USERNAME" />

    <property name="password" value="YOUR_DB_PASSWORD" />

</bean>



```



### 3. 테이블 생성



프로젝트 실행 전 아래의 테이블들이 데이터베이스에 생성되어 있어야 합니다.



* `kit_user`: 회원 정보

* `kits`: Kit 메타 데이터

* `kit_items`: Kit에 포함된 라이브러리 상세 정보



### 4. 빌드 및 실행



Maven을 사용하여 프로젝트를 빌드하고 Tomcat 서버에서 실행합니다.



```bash

# Wrapper를 사용하는 경우

./mvnw clean package



```



생성된 WAR 파일을 Tomcat webapps 폴더에 배포하거나 IDE(IntelliJ, Eclipse)를 통해 실행합니다.



## 프로젝트 구조



```

src/main

├── java/org/example/mavenguard

│   ├── controller  # 웹 요청 처리 (Admin, Auth, Kit, Library 등)

│   ├── service     # 비즈니스 로직 (보안 진단, Kit 관리 등)

│   ├── mapper      # DB 접근 인터페이스 (MyBatis)

│   └── vo          # 데이터 객체 (UserVO, KitVO, LibraryVO 등)

├── resources

│   └── mappers     # SQL 쿼리 XML 파일

└── webapp

    ├── WEB-INF

    │   ├── spring  # Spring 설정

    │   └── views   # JSP 파일

    └── resources   # 정적 리소스 (css, js)

```

—



Copyright 2025 MavenGuard Team. All Rights Reserved.