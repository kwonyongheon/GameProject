<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, java.text.SimpleDateFormat" %>
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
    String replyContent = request.getParameter("replyContent");

    if (commentNumberParam == null || replyContent == null || commentNumberParam.isEmpty() || replyContent.isEmpty()) {
        response.getWriter().write("{\"status\":\"error\", \"message\":\"댓글 번호와 답글 내용을 모두 입력해주세요.\"}");
        return;
    }

    int commentNumber;
    try {
        commentNumber = Integer.parseInt(commentNumberParam);
    } catch (NumberFormatException e) {
        response.getWriter().write("{\"status\":\"error\", \"message\":\"유효한 댓글 번호를 입력해주세요.\"}");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sk_inside", "root", "onlyroot");

        String insertReplySql = "INSERT INTO post_reply (post_comment_number, member_number, writing_time, comment_content) VALUES (?, ?, NOW(), ?)";
        pstmt = conn.prepareStatement(insertReplySql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setInt(1, commentNumber);
        pstmt.setInt(2, loggedInMemberNumber);
        pstmt.setString(3, replyContent);
        pstmt.executeUpdate();

        ResultSet generatedKeys = pstmt.getGeneratedKeys();
        int replyNumber = 0;
        if (generatedKeys.next()) {
            replyNumber = generatedKeys.getInt(1);
        }
        generatedKeys.close();
        pstmt.close();

        String getNicknameSql = "SELECT nickname FROM member WHERE membership_number = ?";
        pstmt = conn.prepareStatement(getNicknameSql);
        pstmt.setInt(1, loggedInMemberNumber);
        ResultSet rs = pstmt.executeQuery();
        String nickname = "";
        if (rs.next()) {
            nickname = rs.getString("nickname");
        }
        rs.close();

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String writingTime = sdf.format(new java.util.Date());

        response.getWriter().write("{\"status\":\"success\", \"replyNumber\":\"" + replyNumber + "\", \"nickname\":\"" + nickname + "\", \"commentContent\":\"" + replyContent + "\", \"writingTime\":\"" + writingTime + "\"}");
    } catch (Exception e) {
        e.printStackTrace();
        response.getWriter().write("{\"status\":\"error\", \"message\":\"답글 작성 중 오류가 발생했습니다.\"}");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>