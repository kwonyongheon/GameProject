<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*, Service.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login</title>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");
	DB.loadConnect();
    String id = request.getParameter("id");
    String password = request.getParameter("password");
    ResultSet rs = DB.LoginService(id, password);
    
    if (rs.next()) { 
    	// 로그인 성공
        session = request.getSession();
        session.setAttribute("membership_number", rs.getInt("membership_number"));
        out.println("<script>window.location.replace('index.jsp');</script>");
    } else {
        // 로그인 실패
        out.println("<script>alert('로그인 실패. 아이디 또는 비밀번호를 확인하세요.'); history.back();</script>");
    }

	DB.disconnect();
%>
</body>
</html>