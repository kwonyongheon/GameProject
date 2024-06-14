<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*, Service.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>updateInfo</title>
</head>
<body>
	<%
    request.setCharacterEncoding("UTF-8");
	DB.loadConnect();
	int membership_number = (Integer)session.getAttribute("membership_number");
    String oldPassword = request.getParameter("oldPassword");
    String newPassword = request.getParameter("newPassword");
    String newPassword_Check = request.getParameter("newPassword_Check");
       
    String password = null;
    ResultSet rs = DB.FindByMembership_number(membership_number);
    if(rs.next()){
    	password = rs.getString("password");
    }
    
    if(!DB.hashPassword(oldPassword).equals(password)) {
    	out.println("<script>alert('현재 비밀번호를 다시 확인해주세요.'); history.back();</script>");
    } else {
    	if(newPassword.equals(newPassword_Check)) {
    		int PWresult = DB.updatePWService(newPassword, membership_number);
    		if(PWresult == -1){
    			out.println("<script>alert('이미 사용중인 비밀번호 입니다.'); history.back();</script>");
    		} else if(PWresult == -2) {
    			out.println("<script>alert('PW작성 방법 : 최소 8자 이상이고, 숫자와 특수문자를 각각 하나 이상 포함하세요. 예시: password1@, 1234abcd#'); history.back();</script>");
    		} else if (PWresult > 0) {
    			out.println("<script>alert('비밀번호가 변경되었습니다.'); location.replace('content.jsp');</script>");
    		} else if (PWresult == 0) {
    			out.println("<script>alert('비밀번호를 변경할 수 없습니다. 관리자에게 문의하세요.'); history.back();</script>");
    		}
    	} else {
    		out.println("<script>alert('새 비밀번호를 다시 확인해주세요.'); history.back();</script>");
    	}
    }
    
    
    
    
	DB.disconnect();
%>
</body>
</html>