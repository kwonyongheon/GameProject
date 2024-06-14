<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*, Service.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>editNickName</title>
</head>
<body>
	<%
    request.setCharacterEncoding("UTF-8");
	DB.loadConnect();
	int membership_number = (Integer)session.getAttribute("membership_number");
    String nickname = request.getParameter("nickname");
    
    int nickNameresult = DB.updateNickNameService(nickname, membership_number);
    if(nickNameresult == 0) {
    	out.println("<script>alert('닉네임을 변경할 수 없습니다. 관리자에게 문의하십시오.'); history.back();</script>");
    } else if (nickNameresult == -1) {
    	out.println("<script>alert('닉네임 작성 방법 : 최소 1글자 이상 14글자 이하 및 처음과 끝은 공백으로 끝날 수 없음.'); history.back();</script>");
    } else if (nickNameresult > 0) {
    	out.println("<script>alert('닉네임이 변경되었습니다.'); location.replace('content.jsp');</script>");
    }
    
    
	DB.disconnect();
%>
</body>
</html>