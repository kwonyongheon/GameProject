<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*" %>
<%
    String commentIdParam = request.getParameter("comment_id");
    session = request.getSession(false);
    if (session == null || session.getAttribute("membership_number") == null) {
        response.getWriter().write("로그인이 필요합니다.");
        return;
    }

    int loggedInMemberNumber = (int) session.getAttribute("membership_number");

    if (commentIdParam == null || commentIdParam.isEmpty()) {
        response.getWriter().write("잘못된 요청입니다.");
        return;
    }

    int commentId;
    try {
        commentId = Integer.parseInt(commentIdParam);
    } catch (NumberFormatException e) {
        response.getWriter().write("유효한 댓글 ID를 입력해주세요.");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sk_inside", "root", "onlyroot");

        // 댓글 작성자 확인
        String commentAuthorSql = "SELECT member_number FROM problem_comment WHERE problem_comment_number = ?";
        pstmt = conn.prepareStatement(commentAuthorSql);
        pstmt.setInt(1, commentId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            int commentAuthor = rs.getInt("member_number");
            if (commentAuthor == loggedInMemberNumber) {
                response.getWriter().write("자신의 댓글에는 추천할 수 없습니다.");
                return;
            }
        }
        rs.close();
        pstmt.close();

        // 추천 상태 확인 및 변경
        String checkRecommendationSql = "SELECT check_member_recommendations FROM problem_comment_recommendations WHERE problem_comment_number = ? AND member_number = ?";
        pstmt = conn.prepareStatement(checkRecommendationSql);
        pstmt.setInt(1, commentId);
        pstmt.setInt(2, loggedInMemberNumber);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            boolean checkMemberRecommendations = rs.getBoolean("check_member_recommendations");
            rs.close();
            pstmt.close();

            if (checkMemberRecommendations) {
                // 추천 취소
                String updateRecommendationSql = "UPDATE problem_comment_recommendations SET check_member_recommendations = FALSE WHERE problem_comment_number = ? AND member_number = ?";
                pstmt = conn.prepareStatement(updateRecommendationSql);
                pstmt.setInt(1, commentId);
                pstmt.setInt(2, loggedInMemberNumber);
                pstmt.executeUpdate();
                pstmt.close();

                String decrementLikesSql = "UPDATE problem_comment SET number_of_recommendations = number_of_recommendations - 1 WHERE problem_comment_number = ?";
                pstmt = conn.prepareStatement(decrementLikesSql);
                pstmt.setInt(1, commentId);
                pstmt.executeUpdate();

                response.getWriter().write("추천이 취소되었습니다.");
            } else {
                // 추천 추가
                String updateRecommendationSql = "UPDATE problem_comment_recommendations SET check_member_recommendations = TRUE WHERE problem_comment_number = ? AND member_number = ?";
                pstmt = conn.prepareStatement(updateRecommendationSql);
                pstmt.setInt(1, commentId);
                pstmt.setInt(2, loggedInMemberNumber);
                pstmt.executeUpdate();
                pstmt.close();

                String incrementLikesSql = "UPDATE problem_comment SET number_of_recommendations = number_of_recommendations + 1 WHERE problem_comment_number = ?";
                pstmt = conn.prepareStatement(incrementLikesSql);
                pstmt.setInt(1, commentId);
                pstmt.executeUpdate();

                response.getWriter().write("추천이 완료되었습니다.");
            }
        } else {
            // 추천 기록이 없는 경우 -> 추천 추가
            String insertRecommendationSql = "INSERT INTO problem_comment_recommendations (problem_comment_number, member_number, check_member_recommendations) VALUES (?, ?, TRUE)";
            pstmt = conn.prepareStatement(insertRecommendationSql);
            pstmt.setInt(1, commentId);
            pstmt.setInt(2, loggedInMemberNumber);
            pstmt.executeUpdate();
            pstmt.close();

            String incrementLikesSql = "UPDATE problem_comment SET number_of_recommendations = number_of_recommendations + 1 WHERE problem_comment_number = ?";
            pstmt = conn.prepareStatement(incrementLikesSql);
            pstmt.setInt(1, commentId);
            pstmt.executeUpdate();

            response.getWriter().write("추천이 완료되었습니다.");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.getWriter().write("추천 중 오류가 발생했습니다.");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
