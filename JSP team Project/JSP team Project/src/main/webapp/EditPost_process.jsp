<%@ page import="java.util.*, Board.*, Service.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시물 수정 완료</title>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    DB.loadConnect();
    // 파라미터로부터 게시물 번호, 제목, 내용 가져오기
    int postNumber = Integer.parseInt(request.getParameter("post_number"));
    String postTitle = request.getParameter("post_title");
    String postContent = request.getParameter("post_content");

    // 게시물 수정 메서드 호출
    DB.updatePost(postNumber, postTitle, postContent);
    DB.disconnect();
%>
    <script>
        alert("게시물이 성공적으로 수정되었습니다.");
        window.location.href = "PostList.jsp";
    </script>
</body>
</html>
