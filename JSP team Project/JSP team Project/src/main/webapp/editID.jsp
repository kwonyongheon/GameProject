<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*, Service.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>editID</title>
</head>
<body>
	<%
    request.setCharacterEncoding("UTF-8");
	DB.loadConnect();
	int membership_number = (Integer)session.getAttribute("membership_number");
    String id = request.getParameter("ID");
    
    int Idresult = DB.updateIdService(id, membership_number);
    if(Idresult == -1) {
    	out.println("<script>alert('이미 사용중인 아이디입니다.'); history.back();</script>");
    } else if (Idresult == -2) {
    	out.println("<script>alert('ID작성 방법 : 알파벳 대소문자와 숫자로 작성하세요. 예시: abc123, 16198, HelloWorld.'); history.back();</script>");
    } else if (Idresult > 0) {
    	out.println("<script>alert('아이디가 변경되었습니다.'); location.replace('content.jsp');</script>");
    } else if (Idresult == 0) {
    	out.println("<script>alert('아이디를 변경할 수 없습니다. 관리자에게 문의하세요.'); history.back();</script>");
    }
    
    
	DB.disconnect();
%>
</body>
</html>