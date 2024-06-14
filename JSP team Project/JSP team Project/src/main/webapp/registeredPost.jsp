<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="registeredPost.css" rel="stylesheet">
<title>글쓰기</title>
</head>
<body>
	<%
	request.setCharacterEncoding("UTF-8");
	session = request.getSession();
	Integer memberNumber = (Integer) session.getAttribute("membership_number");
	if (memberNumber == null) {
		response.sendRedirect("LoginForm.html");
		return;
	}
	%>
	<div class="container">
		<form action="/JSP_team_Project/postUpload" method="post"
			enctype="multipart/form-data">
			<h2 style="text-align: center; margin-bottom: 20px;">글쓰기</h2>
			<div class="form-group">
				<label class="header" for="post_title">제목</label> <input type="text"
					id="post_title" placeholder="제목을 입력하세요" name="title" required>
			</div>
			<div class="form-group">
				<label class="header" for="post_content">내용</label>
				<textarea id="post_content" placeholder="내용을 입력하세요" name="content"
					rows="6" required></textarea>
			</div>
			<div class="form-group file-upload">
				<label class="header" for="file">파일 업로드</label> <input type="file"
					id="file" name="file">
			</div>
			<input type="submit" value="등록">
		</form>
	</div>
</body>
</html>
