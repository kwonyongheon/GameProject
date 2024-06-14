<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>신고 목록 선택</title>
<style>
html, body {
	margin: 0;
	padding: 0;
	overflow: hidden;
	height: 100%;
	width: 100%;
}

body {
	font-family: Arial, sans-serif;
	display: flex;
	justify-content: center;
	align-items: center;
}

.container {
	background-color: #fff;
	border-radius: 8px;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	padding: 20px;
	text-align: center;
	display: flex;
	flex-direction: column;
}

.button {
	background-color: #007bff;
	color: white;
	border: none;
	padding: 10px 20px;
	margin: 10px 0;
	cursor: pointer;
	border-radius: 4px;
	text-decoration: none;
}

.button:hover {
	background-color: #0056b3;
}
</style>
</head>
<body>
	<div class="container">
		<h2>신고 목록</h2>
		<a href="Show_report_post.jsp" class="button">게시물 댓글</a> <a
			href="Show_report_problem.jsp" class="button">문제 댓글</a> <a
			href="Show_report_post_reply.jsp" class="button">게시물 답글</a> <a
			href="Show_report_problem_reply.jsp" class="button">문제 답글</a>
	</div>
</body>
</html>
