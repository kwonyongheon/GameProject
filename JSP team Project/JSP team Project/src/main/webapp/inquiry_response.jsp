<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*, javax.servlet.http.*, Service.*"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="inquiry_response.css" rel="stylesheet">
<title>답장 작성</title>
</head>
<body>
	<%
	request.setCharacterEncoding("UTF-8");
	DB.loadConnect();

	session = request.getSession();
	Integer membership_number = (Integer) session.getAttribute("membership_number");
	if (membership_number == null) {
		out.println("<h2>권한이 없습니다.</h2>");
		return;
	}
	
	Integer inquiryNumber = Integer.parseInt(request.getParameter("inquiryNumber"));
	String title = "";
	String content = "";

	try {
		ResultSet rs = DB.FindInquiry(inquiryNumber);
		if (rs.next()) {
			title = rs.getString("inquiry_title");
			content = rs.getString("inquiry_content");
		}
	} catch (SQLException e) {
		e.printStackTrace();
		out.println("<script>alert('FindInquiry() 실행중 오류발생. 서버확인바람.'); history.back();</script>");
	}
	%>
	<div class="container">
		<h1>문의 제목: <%=title %></h1>
		<p>문의 내용:</p>
		<p><%=content%></p>
		<form action="submit_response.jsp" method="POST"
			accept-charset="UTF-8">
			<table class="form-table">
				<tr>
					<td>답장 내용 :</td>
					<td><textarea id="answerContent" name="answerContent"
							rows="10" cols="50" required style="height: 200px;"></textarea></td>
				</tr>
				<tr>
					<td colspan="2" class="right-align"><input type="hidden"
						name="inquiryNumber" value="<%=inquiryNumber%>"> <input
						type="submit" value="답장 보내기"></td>
				</tr>
			</table>
		</form>
	</div>
</body>
</html>
