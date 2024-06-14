<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*, Service.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Join</title>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");
	DB.loadConnect();
    String id = request.getParameter("id");
    String password = request.getParameter("password");
    String nickname = request.getParameter("nickname");
    String name = request.getParameter("name");
    String gender = request.getParameter("gender");
  
    int result = DB.JoinService(id, password, nickname, name, gender);  
    
        if (result > 0) {
            out.println("<script>alert('회원 가입이 성공적으로 완료되었습니다.'); location.replace('LoginForm.html');</script>");
        } else if (result == -1) {
            out.println("<script>alert('이미 가입된 아이디입니다. 다른 아이디로 가입해주세요.'); history.back();</script>");
        } else if (result == -2) {
            out.println("<script>alert('ID작성 방법 : 알파벳 대소문자와 숫자로 작성하세요. 예시: abc123, 16198, HelloWorld'); history.back();</script>");
        } else if (result == -3) {
            out.println("<script>alert('PW작성 방법 : 최소 8자 이상이고, 숫자와 특수문자를 각각 하나 이상 포함하세요. 예시: password1@, 1234abcd#'); history.back();</script>");
        } else if (result == -4) {
        	out.println("<script>alert('닉네임 작성 방법 : 최소 1글자 이상 14글자 이하 및 처음과 끝은 공백으로 끝날 수 없음.'); history.back();</script>");
        } else if (result == -5) {
        	out.println("<script>alert('이름 작성 방법 : 두 글자에서 다섯 글자 사이의 한글 문자로 작성.'); history.back();</script>");
        } else if (result ==0) {
        	out.println("<script>alert('회원 가입에 오류가 발생했습니다. 관리자에게 문의하세요.'); history.back();</script>");
        }
     
    DB.disconnect();
%>
</body>
</html>