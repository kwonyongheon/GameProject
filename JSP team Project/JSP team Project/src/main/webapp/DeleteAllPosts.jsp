<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, java.io.File" %>

<%
    session = request.getSession(false);
    if (session == null || session.getAttribute("membership_number") == null) {
        response.sendRedirect("LoginForm.html");
        return;
    }

    int membership_number = (Integer) session.getAttribute("membership_number");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sk_inside", "root", "onlyroot");

        // 트랜잭션 시작
        conn.setAutoCommit(false);

        // 첨부파일 경로
        String uploadDir = "C:\\Users\\ksk69\\desktop\\바탕 화면\\DP programing\\JSP team Project\\src\\main\\webapp\\fileSave\\";

        // 첨부파일 삭제
        String selectAttachmentsSql = "SELECT attached_file_name FROM post_attachment_file WHERE post_number IN (SELECT post_number FROM post WHERE member_number = ?)";
        pstmt = conn.prepareStatement(selectAttachmentsSql);
        pstmt.setInt(1, membership_number);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            String fileName = rs.getString("attached_file_name");
            File file = new File(uploadDir + fileName);
            if (file.exists()) {
                file.delete();
            }
        }
        rs.close();
        pstmt.close();

        // 첨부 파일 DB 삭제
        String deleteAttachedFilesSql = "DELETE FROM post_attachment_file WHERE post_number IN (SELECT post_number FROM post WHERE member_number = ?)";
        pstmt = conn.prepareStatement(deleteAttachedFilesSql);
        pstmt.setInt(1, membership_number);
        pstmt.executeUpdate();
        pstmt.close();

        // 댓글 추천 내역 삭제
        String deleteCommentRecommendationsSql = "DELETE FROM post_comment_recommendations WHERE post_comment_number IN (SELECT post_comment_number FROM post_comments WHERE post_number IN (SELECT post_number FROM post WHERE member_number = ?))";
        pstmt = conn.prepareStatement(deleteCommentRecommendationsSql);
        pstmt.setInt(1, membership_number);
        pstmt.executeUpdate();
        pstmt.close();

        // 답글 추천 내역 삭제
        String deleteReplyRecommendationsSql = "DELETE FROM post_reply_recommendations WHERE post_reply_number IN (SELECT post_reply_number FROM post_reply WHERE post_comment_number IN (SELECT post_comment_number FROM post_comments WHERE post_number IN (SELECT post_number FROM post WHERE member_number = ?)))";
        pstmt = conn.prepareStatement(deleteReplyRecommendationsSql);
        pstmt.setInt(1, membership_number);
        pstmt.executeUpdate();
        pstmt.close();

        // 답글 신고 내역 삭제
        String deleteReplyReportsSql = "DELETE FROM report_post_reply WHERE post_reply_number IN (SELECT post_reply_number FROM post_reply WHERE post_comment_number IN (SELECT post_comment_number FROM post_comments WHERE post_number IN (SELECT post_number FROM post WHERE member_number = ?)))";
        pstmt = conn.prepareStatement(deleteReplyReportsSql);
        pstmt.setInt(1, membership_number);
        pstmt.executeUpdate();
        pstmt.close();

        // 답글 삭제
        String deleteReplySql = "DELETE FROM post_reply WHERE post_comment_number IN (SELECT post_comment_number FROM post_comments WHERE post_number IN (SELECT post_number FROM post WHERE member_number = ?))";
        pstmt = conn.prepareStatement(deleteReplySql);
        pstmt.setInt(1, membership_number);
        pstmt.executeUpdate();
        pstmt.close();

        // 댓글 신고 내역 삭제
        String deleteCommentReportsSql = "DELETE FROM report_post_comment WHERE post_comment_number IN (SELECT post_comment_number FROM post_comments WHERE post_number IN (SELECT post_number FROM post WHERE member_number = ?))";
        pstmt = conn.prepareStatement(deleteCommentReportsSql);
        pstmt.setInt(1, membership_number);
        pstmt.executeUpdate();
        pstmt.close();

        // 댓글 삭제
        String deleteCommentsSql = "DELETE FROM post_comments WHERE post_number IN (SELECT post_number FROM post WHERE member_number = ?)";
        pstmt = conn.prepareStatement(deleteCommentsSql);
        pstmt.setInt(1, membership_number);
        pstmt.executeUpdate();
        pstmt.close();

        // 게시물 추천 삭제
        String deletePostRecommendationsSql = "DELETE FROM post_recommendations WHERE post_number IN (SELECT post_number FROM post WHERE member_number = ?)";
        pstmt = conn.prepareStatement(deletePostRecommendationsSql);
        pstmt.setInt(1, membership_number);
        pstmt.executeUpdate();
        pstmt.close();

        // 게시물 삭제
        String deletePostsSql = "DELETE FROM post WHERE member_number = ?";
        pstmt = conn.prepareStatement(deletePostsSql);
        pstmt.setInt(1, membership_number);
        pstmt.executeUpdate();
        pstmt.close();

        conn.commit();
        response.getWriter().println("<script>alert('모든 게시물이 삭제되었습니다.'); location.href='MyPosts.jsp';</script>");
    } catch (Exception e) {
        e.printStackTrace();
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
        response.getWriter().println("<script>alert('게시물 삭제 중 오류가 발생했습니다.'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
