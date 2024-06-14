<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*, javax.servlet.http.*, Service.*"%>
<%
	request.setCharacterEncoding("UTF-8");  
	DB.loadConnect();
	
	Integer inquiryNumber = Integer.parseInt(request.getParameter("inquiryNumber"));
	String answerContent = request.getParameter("answerContent");
	
	int rowsInserted = DB.sendInquiryResponse(inquiryNumber, answerContent);

    if (rowsInserted > 0) {
        out.println("<script>alert('답장이 성공적으로 전송되었습니다!'); location.href='inquiry_list.jsp';</script>");
    } else {
        out.println("<script>alert('답장 전송에 실패하였습니다!'); history.back();</script>");
    }

%>
