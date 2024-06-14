<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String replyNumberParam = request.getParameter("replyNumber");
    String newContent = request.getParameter("newContent");

    session = request.getSession(false);
    if (session == null || session.getAttribute("membership_number") == null) {
        response.getWriter().write("로그인이 필요합니다.");
        return;
    }

    int loggedInMemberNumber = (int) session.getAttribute("membership_number");

    if (replyNumberParam == null || replyNumberParam.isEmpty() || newContent == null || newContent.isEmpty()) {
        response.getWriter().write("잘못된 요청입니다.");
        return;
    }

    int replyNumber;
    try {
        replyNumber = Integer.parseInt(replyNumberParam);
    } catch (NumberFormatException e) {
        response.getWriter().write("유효한 답글 번호를 입력해주세요.");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sk_inside", "root", "onlyroot");

        String sql = "UPDATE post_reply SET comment_content = ? WHERE post_reply_number = ? AND member_number = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, newContent);
        pstmt.setInt(2, replyNumber);
        pstmt.setInt(3, loggedInMemberNumber);
        int rowsAffected = pstmt.executeUpdate();

        if (rowsAffected > 0) {
            response.getWriter().write("답글이 수정되었습니다.");
        } else {
            response.getWriter().write("답글 수정에 실패했습니다.");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.getWriter().write("답글 수정 중 오류가 발생했습니다.");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
