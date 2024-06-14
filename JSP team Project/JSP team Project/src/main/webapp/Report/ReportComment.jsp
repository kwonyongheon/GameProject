<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, java.text.SimpleDateFormat" %>
<%
    request.setCharacterEncoding("UTF-8");

    int commentId = Integer.parseInt(request.getParameter("comment_id"));
    session = request.getSession(false);
    if (session == null || session.getAttribute("membership_number") == null) {
        response.getWriter().write("로그인이 필요합니다.");
        return;
    }

    int loggedInMemberNumber = (int) session.getAttribute("membership_number");

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
                response.getWriter().write("자신의 댓글은 신고할 수 없습니다.");
                return;
            }
        }
        rs.close();
        pstmt.close();

        // 신고 이력 확인
        String checkReportSql = "SELECT * FROM report_problem_comment WHERE problem_comment_number = ? AND member_number = ?";
        pstmt = conn.prepareStatement(checkReportSql);
        pstmt.setInt(1, commentId);
        pstmt.setInt(2, loggedInMemberNumber);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            response.getWriter().write("이미 신고한 댓글입니다.");
        } else {
            String reportSql = "INSERT INTO report_problem_comment (problem_comment_number, member_number, report_date) VALUES (?, ?, CURRENT_TIMESTAMP)";
            pstmt = conn.prepareStatement(reportSql);
            pstmt.setInt(1, commentId);
            pstmt.setInt(2, loggedInMemberNumber);
            pstmt.executeUpdate();

            response.getWriter().write("신고가 완료되었습니다.");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.getWriter().write("신고 중 오류가 발생했습니다.");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
