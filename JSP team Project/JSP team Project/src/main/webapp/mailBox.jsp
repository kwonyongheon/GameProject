<%@ page language="java" contentType="text/html;charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*, javax.servlet.http.*, Service.*"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link href="mailBox.css" rel="stylesheet">
<title>mailBox</title>
</head>
<body>

	<%
	request.setCharacterEncoding("UTF-8");

	Integer membershipNumber = (Integer) session.getAttribute("membership_number");
	if (membershipNumber == null) {
		response.sendRedirect("LoginForm.html");
		return;
	}
	DB.loadConnect();

	if (request.getParameter("delete") != null) {
		try {
			int inquiryNumber = Integer.parseInt(request.getParameter("inquiry_number"));

			DB.DeleteInquiryTransaction(inquiryNumber, membershipNumber);

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			out.println("<script>alert('삭제오류. 관리자에게 문의하세요.');</script>");
			e.printStackTrace();
		}

	}

	try {
		ResultSet rs = DB.FindInquiryInfo(membershipNumber);

		out.println("<div class=\"container\">");
		out.println("<div class=\"mailbox-header\">");
		out.println("<h1 class=\"mailbox-title\">편지함</h1>");
		out.println("</div>");

		while (rs.next()) {
			int inquiryNumber = rs.getInt("inquiry_number");
			String inquiryTitle = rs.getString("inquiry_title");
			String inquiryContent = rs.getString("inquiry_content");
			String answerContent = rs.getString("answer_content");

			out.println("<div class=\"inquiry\">");
			out.println("<h2>문의 제목: " + inquiryTitle + "</h2>");
			out.println("<p>문의 내용: " + inquiryContent + "</p>");
			if (answerContent != null) {
		out.println("<p><strong>답장 내용:</strong> " + answerContent + "</p>");
			} else {
		out.println("<p><strong>답장 내용:</strong> 답장이 없습니다.</p>");
			}
			out.println("<form method='post' action=''>");
			out.println("<input type='hidden' name='inquiry_number' value='" + inquiryNumber + "'>");
			out.println("<button type='submit' name='delete' value='1'>삭제</button>");
			out.println("</form>");
			out.println("</div>");
		}

		out.println("</div>");
	} catch (Exception e) {
		e.printStackTrace();
		out.println("<script>alert('오류: " + e.getMessage() + "');</script>");
	}

	DB.disconnect();
	%>
</body>
</html>