<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="inquiry.css" rel="stylesheet">
<title>문의하기</title>
</head>
<body>
	<%
	session = request.getSession();
	Integer memberNumber = (Integer) session.getAttribute("membership_number");
	if (memberNumber == null) {
		response.sendRedirect("LoginForm.html");
		return;
	}
	%>
	<div class="container">
		<h1 align="center">문의내용 작성 양식</h1>
		<form action="/JSP_team_Project/upload" method="post"
			accept-charset="UTF-8" enctype="multipart/form-data">
			<table class="form-table">
				<tr>
					<td>문의제목 :</td>
					<td><input type="text" name="title" size="50"></td>
				</tr>
				<tr>
					<td>문의내용 :</td>
					<td><textarea id="content" name="content" rows="10" cols="50"
							required style="height: 200px;"></textarea></td>
				</tr>
				<tr>
					<td>첨부파일 :</td>
					<td><input type="file" name="file"></td>
				</tr>
				<tr>
					<td colspan="2" class="right-align"><input type="reset"
						value="초기화"> <input type="submit" value="문의글 보내기"></td>
				</tr>
			</table>
		</form>
	</div>
</body>
</html>
