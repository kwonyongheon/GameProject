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

    int loggedInmembership_number = (int) session.getAttribute("membership_number");
    String commentNumberParam = request.getParameter("commentNumber");

    if (commentNumberParam == null || commentNumberParam.isEmpty()) {
        response.getWriter().write("{\"status\":\"error\", \"message\":\"댓글 번호가 필요합니다.\"}");
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
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/SK_inside", "root", "onlyroot");

        // 트랜잭션 시작
        conn.setAutoCommit(false);
        
        // 댓글 추천 내역 삭제
        String deleteCommentRecommendationsSql = "DELETE FROM post_comment_recommendations WHERE post_comment_number = ?";
        pstmt = conn.prepareStatement(deleteCommentRecommendationsSql);
        pstmt.setInt(1, commentNumber);
        pstmt.executeUpdate();
        pstmt.close();
        
        // 답글 추천 내역 삭제
        String deleteReplyRecommendationsSql = "DELETE FROM post_reply_recommendations WHERE post_reply_number IN (SELECT post_reply_number FROM post_reply WHERE post_comment_number = ?)";
        pstmt = conn.prepareStatement(deleteReplyRecommendationsSql);
        pstmt.setInt(1, commentNumber);
        pstmt.executeUpdate();
        pstmt.close();
        
        // 답글 신고 내역 삭제
        String deleteReplyReportsSql = "DELETE FROM report_post_reply WHERE post_reply_number IN (SELECT post_reply_number FROM post_reply WHERE post_comment_number = ?)";
        pstmt = conn.prepareStatement(deleteReplyReportsSql);
        pstmt.setInt(1, commentNumber);
        pstmt.executeUpdate();
        pstmt.close();

        // 답글 삭제
        String deleteReplySql = "DELETE FROM post_reply WHERE post_comment_number = ?";
        pstmt = conn.prepareStatement(deleteReplySql);
        pstmt.setInt(1, commentNumber);
        pstmt.executeUpdate();
        pstmt.close();

        // 댓글 신고 내역 삭제
        String deleteCommentReportsSql = "DELETE FROM report_post_comment WHERE post_comment_number = ?";
        pstmt = conn.prepareStatement(deleteCommentReportsSql);
        pstmt.setInt(1, commentNumber);
        pstmt.executeUpdate();
        pstmt.close();

        // 댓글 삭제
        String deleteCommentSql = "DELETE FROM post_comments WHERE post_comment_number = ? AND member_number = ?";
        pstmt = conn.prepareStatement(deleteCommentSql);
        pstmt.setInt(1, commentNumber);
        pstmt.setInt(2, loggedInmembership_number);

        int rowsAffected = pstmt.executeUpdate();
        if (rowsAffected > 0) {
            conn.commit();
            response.getWriter().write("{\"status\":\"success\", \"message\":\"댓글이 삭제되었습니다.\"}");
        } else {
            conn.rollback();
            response.getWriter().write("{\"status\":\"error\", \"message\":\"댓글 삭제에 실패했습니다.\"}");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
        response.getWriter().write("{\"status\":\"error\", \"message\":\"댓글 삭제 중 오류가 발생했습니다: " + e.getMessage() + "\"}");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
