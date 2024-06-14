<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="javax.servlet.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>문제 대댓글 삭제</title>
</head>
<body>
<%
    // Get parameters
    int problemReplyNumber = Integer.parseInt(request.getParameter("problem_reply_number"));
    int reportNumber = Integer.parseInt(request.getParameter("report_number"));

    // JDBC connection parameters
    String url = "jdbc:mysql://localhost:3306/sk_inside"; // replace with your database URL
    String user = "root"; // replace with your database username
    String password = "onlyroot"; // replace with your database password

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // Load JDBC driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Establish connection
        conn = DriverManager.getConnection(url, user, password);

        // Start transaction
        conn.setAutoCommit(false);

        // 1. Delete the report entry from report_problem_reply
        String sql1 = "DELETE FROM report_problem_reply WHERE report_number = ?";
        pstmt = conn.prepareStatement(sql1);
        pstmt.setInt(1, reportNumber);
        pstmt.executeUpdate();
        pstmt.close();

        // 2. Delete problem_reply_recommendations related to this problem reply
        String sql2 = "DELETE FROM problem_reply_recommendations WHERE problem_reply_number = ?";
        pstmt = conn.prepareStatement(sql2);
        pstmt.setInt(1, problemReplyNumber);
        pstmt.executeUpdate();
        pstmt.close();

        // 3. Delete the problem reply itself
        String sql3 = "DELETE FROM problem_reply WHERE problem_reply_number = ?";
        pstmt = conn.prepareStatement(sql3);
        pstmt.setInt(1, problemReplyNumber);
        pstmt.executeUpdate();
        pstmt.close();

        // Commit transaction
        conn.commit();
        response.sendRedirect("Show_report_problem_reply.jsp");
    } catch (Exception e) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        e.printStackTrace();
    } finally {
        // Close resources
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
</body>
</html>