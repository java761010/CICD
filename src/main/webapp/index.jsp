
<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Hello CI/CD - Jenkins 배포 테스트</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background-color: #f4f6f9;
        }

        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            max-width: 650px;
            margin: auto;
        }

        h1 {
            color: #2c3e50;
        }

        .button {
            display: inline-block;
            padding: 12px 20px;
            margin: 10px 10px 10px 0;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }

        .button:hover {
            background-color: #0056b3;
        }
    </style>
</head>

<body>
    <div class="container">

        <h1>Hello CI/CD</h1>

        <h2>Jenkins 배포 테스트 cicd</h2>

        <p>
            Windows Jenkins →
            Linux Tomcat Deployment
        </p>

        <p>
            Spring Boot / Servlet / JSP 테스트 화면.
        </p>

        <hr>

        <h3>Servlet 기능 테스트</h3>

        <a class="button"
           href="${pageContext.request.contextPath}/hello">
            Hello Servlet 실행
        </a>

        <a class="button"
           href="${pageContext.request.contextPath}/health">
            Health Check 실행
        </a>

        <hr>sdfsdfsd

        <p>
            Context Path:
            ${pageContext.request.contextPath}
        </p>

    </div>
</body>
</html>
