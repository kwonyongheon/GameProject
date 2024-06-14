<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>신고된 문제 대댓글 목록</title>
    <style>
	    html, body 
		{
		    margin: 0;
		    padding: 0;
		    overflow: hidden;
		    height: 100%;
		    width: 100%;
		}
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .delete-btn {
            background-color: #f44336;
            color: white;
            border: none;
            padding: 5px 10px;
            cursor: pointer;
            border-radius: 4px;
        }
        .delete-btn:hover {
            background-color: #d32f2f;
        }
    </style>
</head>
<body>
    <h2>신고된 문제 대댓글 목록</h2>
    <table>
        <thead>
            <tr>
                <th>신고번호</th>
                <th>문제 대댓글 번호</th>
                <th>회원번호</th>
                <th>신고일</th>
                <th>댓글 삭제</th>
            </tr>
        </thead>
        <tbody>
            <%
                // JDBC connection parameters
                String url = "jdbc:mysql://localhost:3306/sk_inside"; // replace with your database URL
                String user = "root"; // replace with your database username
                String password = "onlyroot"; // replace with your database password

                Connection conn = null;
                PreparedStatement stmt = null;
                ResultSet rs = null;

                try {
                    // Load JDBC driver
                    Class.forName("com.mysql.cj.jdbc.Driver");

                    // Establish connection
                    conn = DriverManager.getConnection(url, user, password);

                    // Prepare statement
                    String sql = "SELECT report_number, problem_reply_number, member_number, report_date FROM report_problem_reply";
                    stmt = conn.prepareStatement(sql);

                    // Execute query
                    rs = stmt.executeQuery();

                    // Iterate through the result set and display data
                    while (rs.next()) {
                        int reportNumber = rs.getInt("report_number");
                        int problemReplyNumber = rs.getInt("problem_reply_number");
                        int memberNumber = rs.getInt("member_number");
                        Date reportDate = rs.getDate("report_date");
            %>
                        <tr>
                            <td><%= reportNumber %></td>
                            <td><a href="replyDetails_problem.jsp?problem_reply_number=<%= problemReplyNumber %>"><%= problemReplyNumber %></a></td>
                            <td><%= memberNumber %></td>
                            <td><%= reportDate %></td>
                            <td>
                                <form action="deleteReport_problem_reply.jsp" method="post" style="display:inline;">
                                    <input type="hidden" name="problem_reply_number" value="<%= problemReplyNumber %>">
                                    <input type="hidden" name="report_number" value="<%= reportNumber %>">
                                    <button type="submit" class="delete-btn">삭제</button>
                                </form>
                            </td>
                        </tr>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    // Close resources
                    try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                    try { if (stmt != null) stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                    try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            %>
        </tbody>
    </table>
</body>
</html>
