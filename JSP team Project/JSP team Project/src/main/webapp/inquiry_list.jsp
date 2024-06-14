<%@ page language="java" contentType="text/html;charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*, javax.servlet.http.*, java.io.*, Service.*"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="inquiry_list.css" rel="stylesheet">
<title>문의사항 목록</title>
</head>
<body>
	<%
	request.setCharacterEncoding("UTF-8");
	DB.loadConnect();

	Integer membership_number = (Integer) session.getAttribute("membership_number");
	String permission = null;
	if (membership_number != null) { // null 체크 추가
		ResultSet rs = DB.FindByMembership_number(membership_number);
		if (rs.next()) {
			permission = rs.getString("permission");
		}
		rs.close();
	}

	if (permission != null && permission.equals("관리자")) {
		try {
			ResultSet rs = DB.FindInquiryJoinFileName();
	%>
	<table>
		<tr>
			<th>회원번호</th>
			<th>문의제목</th>
			<th>문의시간</th>
			<th>첨부파일</th>
			<th>답장</th>
		</tr>
		<%
		while (rs.next()) {
			int inquiryNumber = rs.getInt("inquiry_number");
			String title = rs.getString("inquiry_title");
			Timestamp time = rs.getTimestamp("inquiry_time");
			String attachedFileName = rs.getString("attached_file_name");
			int membershipNumber = rs.getInt("membership_number");

			String downloadLink = "downloadFile.jsp?inquiryNumber=" + inquiryNumber;
		%>
		<tr>
			<td><%=membershipNumber%></td>
			<td><%=title%></td>
			<td><%=time%></td>
			<td>
				<%
				if (attachedFileName != null) {
				%> <a href="<%=downloadLink%>"><%=attachedFileName%></a> <%
 } else {
 %> 첨부파일 없음 <%
 }
 %>
			</td>
			<td><a class="response-link"
				href="inquiry_response.jsp?inquiryNumber=<%=inquiryNumber%>">답장하기</a></td>
		</tr>
		<%
		}
		rs.close();
		%>
	</table>
	<%
	} catch (SQLException ex) {
	ex.printStackTrace();
	%>
	<script>
		alert('FindInquiryJoinFileName() 실행중 오류발생. 서버확인바람.');
		history.back();
	</script>
	<%
	}
	} else {
	%>
	<h2>권한이 없습니다.</h2>
	<%
	}

	DB.disconnect();
	%>
</body>
</html>
