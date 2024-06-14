<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*, Service.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>editPhoneNum</title>
</head>
<body>
	<%
    request.setCharacterEncoding("UTF-8");
	DB.loadConnect();
	int membership_number = (Integer)session.getAttribute("membership_number");
    String phone_number = request.getParameter("phone_number");
    
    int PHresult = DB.updatePhoneNumService(phone_number, membership_number);
    if(PHresult == 0) {
    	out.println("<script>alert('전화번호를 변경할 수 없습니다. 관리자에게 문의하십시오.'); history.back();</script>");
    } else if (PHresult == -1) {
    	out.println("<script>alert('올바른 전화번호를 입력해주세요. 전화번호 작성 방법 : - 이나 공백을 통해 중간 구분 혹은 구분없이 전화번호 그대로 입력.'); history.back();</script>");
    } else if (PHresult == -2) {
    	out.println("<script>alert('이미 가입된 전화번호입니다.'); history.back();</script>");
    } else if (PHresult > 0) {
    	out.println("<script>alert('전화번호가 변경되었습니다.'); location.replace('content.jsp');</script>");
    }
    
    
	DB.disconnect();
%>
</body>
</html>