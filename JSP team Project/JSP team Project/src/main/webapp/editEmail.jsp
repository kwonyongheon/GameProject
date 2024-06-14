<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*, Service.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>editEmail</title>
</head>
<body>
	<%
    request.setCharacterEncoding("UTF-8");
	DB.loadConnect();
	int membership_number = (Integer)session.getAttribute("membership_number");
    String email = request.getParameter("email");
    
    int emailresult = DB.updateEmailService(email, membership_number);
    if(emailresult == 0) {
    	out.println("<script>alert('이메일을 변경할 수 없습니다. 관리자에게 문의하십시오.'); history.back();</script>");
    } else if (emailresult == -1) {
    	out.println("<script>alert('올바른 이메일을 입력해주세요. 이메일 작성 예시 : xxxx@XXXX.XXX --> 사용자아이디 + @ + 이용도메인 + . + 최상위 도메인'); history.back();</script>");
    } else if (emailresult > 0) {
    	out.println("<script>alert('이메일이 변경되었습니다.'); location.replace('content.jsp');</script>");
    }
    
    
	DB.disconnect();
%>
</body>
</html>