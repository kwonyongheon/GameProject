<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>신고된 게시물 댓글 내용</title>
    <style>
	    html, body 
		{
		    margin: 0;
		    padding: 0;
		    overflow: hidden;
		    height: 100%;
		    width: 100%;
		}
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            padding: 20px;
            max-width: 600px;
            width: 100%;
        }
        .comment-content {
            font-size: 16px;
            line-height: 1.5;
            margin-bottom: 20px;
        }
        .comment-time {
            font-size: 14px;
            color: #777;
        }
    </style>
</head>
<body>
    <div class="container">
        <%
            int postCommentNumber = Integer.parseInt(request.getParameter("post_comment_number"));

            // JDBC connection parameters
            String url = "jdbc:mysql://localhost:3306/sk_inside"; // replace with your database URL
            String user = "root"; // replace with your database username
            String password = "onlyroot"; // replace with your database password

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                // Load JDBC driver
                Class.forName("com.mysql.cj.jdbc.Driver");

                // Establish connection
                conn = DriverManager.getConnection(url, user, password);

                // Create statement
                String sql = "SELECT comment_content, writing_time FROM post_comments WHERE post_comment_number = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, postCommentNumber);

                // Execute query
                rs = pstmt.executeQuery();

                // Display comment details
                if (rs.next()) {
                    String commentContent = rs.getString("comment_content");
                    Timestamp writingTime = rs.getTimestamp("writing_time");
        %>
                    <div class="comment-content">
                        <p><%= commentContent %></p>
                    </div>
                    <div class="comment-time">
                        <p>작성 시간: <%= writingTime %></p>
                    </div>
        <%
                } else {
        %>
                    <div class="comment-content">
                        <p>해당 댓글을 찾을 수 없습니다.</p>
                    </div>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                // Close resources
                try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        %>
    </div>
</body>
</html>
