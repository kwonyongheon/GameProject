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
    String replyNumberParam = request.getParameter("replyNumber");

    if (replyNumberParam == null || replyNumberParam.isEmpty()) {
        response.getWriter().write("{\"status\":\"error\", \"message\":\"답글 번호가 필요합니다.\"}");
        return;
    }

    int replyNumber;
    try {
        replyNumber = Integer.parseInt(replyNumberParam);
    } catch (NumberFormatException e) {
        response.getWriter().write("{\"status\":\"error\", \"message\":\"유효한 답글 번호가 필요합니다.\"}");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/SK_inside", "root", "onlyroot");

        // 트랜잭션 시작
        conn.setAutoCommit(false);
        
        // 답글 추천 내역 삭제
        String deleteReplyRecommendationsSql = "DELETE FROM post_reply_recommendations WHERE post_reply_number = ?";
        pstmt = conn.prepareStatement(deleteReplyRecommendationsSql);
        pstmt.setInt(1, replyNumber);
        pstmt.executeUpdate();
        pstmt.close();
        
        // 답글 신고 내역 삭제
        String deleteReplyReportsSql = "DELETE FROM report_post_reply WHERE post_reply_number = ?";
        pstmt = conn.prepareStatement(deleteReplyReportsSql);
        pstmt.setInt(1, replyNumber);
        pstmt.executeUpdate();
        pstmt.close();

        // 답글 삭제
        String deleteReplySql = "DELETE FROM post_reply WHERE post_reply_number = ? AND member_number = ?";
        pstmt = conn.prepareStatement(deleteReplySql);
        pstmt.setInt(1, replyNumber);
        pstmt.setInt(2, loggedInMemberNumber);

        int rowsAffected = pstmt.executeUpdate();
        if (rowsAffected > 0) {
            conn.commit();
            response.getWriter().write("{\"status\":\"success\", \"message\":\"답글이 삭제되었습니다.\"}");
        } else {
            response.getWriter().write("{\"status\":\"error\", \"message\":\"답글 삭제에 실패했습니다.\"}");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
        response.getWriter().write("{\"status\":\"error\", \"message\":\"답글 삭제 중 오류가 발생했습니다: " + e.getMessage() + "\"}");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
