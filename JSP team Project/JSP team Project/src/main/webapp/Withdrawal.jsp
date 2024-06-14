<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*, Service.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Withdrawal</title>
</head>
<body>
    <%
    request.setCharacterEncoding("UTF-8");
    DB.loadConnect();
    int membership_number = (Integer)session.getAttribute("membership_number");
    
    boolean withdrawal = DB.withdrawal(membership_number);
    
    // 현재 세션
    javax.servlet.http.HttpSession Session = request.getSession(false);   
    if(withdrawal) {
    // 세션 삭제
    if (Session != null) {
        Session.invalidate();
    }
        out.println("<script>alert('탈퇴되었습니다.');</script>");
        out.println("<script>parent.location.href = 'LoginForm.html';</script>"); // 탈퇴 성공 시 LoginForm.html 페이지로 이동
    } else {
        out.println("<script>alert('탈퇴중 오류발생. 관리자에게 문의하세요');</script>");
    }
    DB.disconnect();
    %>
</body>
</html>
