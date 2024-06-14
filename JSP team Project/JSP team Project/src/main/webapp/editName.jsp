<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*, Service.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>editName</title>
</head>
<body>
	<%
    request.setCharacterEncoding("UTF-8");
	DB.loadConnect();
	int membership_number = (Integer)session.getAttribute("membership_number");
    String name = request.getParameter("name");
    
    int Nameresult = DB.updateNameService(name, membership_number);
    if(Nameresult == 0) {
    	out.println("<script>alert('이름을 변경할 수 없습니다. 관리자에게 문의하십시오.'); history.back();</script>");
    } else if (Nameresult == -1) {
    	out.println("<script>alert('이름 작성 방법 : 두 글자에서 다섯 글자 사이의 한글 문자로 작성.'); history.back();</script>");
    } else if (Nameresult > 0) {
    	out.println("<script>alert('이름이 변경되었습니다.'); location.replace('content.jsp');</script>");
    }
    
    
	DB.disconnect();
%>
</body>
</html>