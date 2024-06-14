<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>LogOut</title>
</head>
<body>
	<%
    // 현재 세션
    javax.servlet.http.HttpSession Session = request.getSession(false);
    
    // 세션 삭제
    if (Session != null) {
        Session.invalidate();
    }
	%>
	<script>
		window.location.replace('LoginForm.html');
	</script>
</body>
</html>