<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    session = request.getSession(false);
    if (session == null || session.getAttribute("membership_number") == null) {
        response.getWriter().write("{\"status\":\"error\", \"message\":\"로그인이 필요합니다.\"}");
        return;
    }

    int loggedInMemberNumber = (int) session.getAttribute("membership_number");
    String commentNumberParam = request.getParameter("commentNumber");
    String newContent = request.getParameter("newContent");

    if (commentNumberParam == null || commentNumberParam.isEmpty() || newContent == null || newContent.isEmpty()) {
        response.getWriter().write("{\"status\":\"error\", \"message\":\"댓글 번호와 새로운 내용이 필요합니다.\"}");
        return;
    }

    int commentNumber;
    try {
        commentNumber = Integer.parseInt(commentNumberParam);
    } catch (NumberFormatException e) {
        response.getWriter().write("{\"status\":\"error\", \"message\":\"유효한 댓글 번호가 필요합니다.\"}");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sk_inside", "root", "onlyroot");

        String updateSql = "UPDATE problem_comment SET comment_content = ? WHERE problem_comment_number = ? AND member_number = ?";
        pstmt = conn.prepareStatement(updateSql);
        pstmt.setString(1, newContent);
        pstmt.setInt(2, commentNumber);
        pstmt.setInt(3, loggedInMemberNumber);

        int rowsAffected = pstmt.executeUpdate();
        if (rowsAffected > 0) {
            response.getWriter().write("{\"status\":\"success\", \"message\":\"댓글이 수정되었습니다.\"}");
        } else {
            response.getWriter().write("{\"status\":\"error\", \"message\":\"댓글 수정에 실패했습니다.\"}");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.getWriter().write("{\"status\":\"error\", \"message\":\"댓글 수정 중 오류가 발생했습니다.\"}");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
