<%@ page import="java.util.*, Service.*, Board.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="MyPostsAndProblems.css" rel="stylesheet">
<title>내 게시물</title>
</head>
<body>
<div class="container">
    <div class="header-container">
        <h2>내 게시물</h2>
        <button class="delete-all-btn" onclick="confirmDeleteAll()">전체 삭제</button>
    </div>
    <table>
    <thead>
        <tr class="header">
            <th class="num">번호</th>
            <th class="title" align="center">제목</th>
            <th>추천수</th>
            <th>조회수</th>
        </tr>
    </thead>
        <tbody>
            <%
            	request.setCharacterEncoding("UTF-8");
        		DB.loadConnect();
                session = request.getSession();
                Integer memberNumber = (Integer) session.getAttribute("membership_number");

                if (memberNumber == null) {
                    response.sendRedirect("LoginForm.html");
                    return;
                }

                int currentPage = 1;
                int postsPerPage = 10;
                if (request.getParameter("page") != null) {
                    currentPage = Integer.parseInt(request.getParameter("page"));
                }
                int startPost = (currentPage - 1) * postsPerPage;
                List<PostDTO> posts = DB.getPostsByMemberNumber(memberNumber, startPost, postsPerPage);
                int displayNumber = startPost + 1;
                for (PostDTO post : posts) {
            %>
                <tr>
                    <td><%= displayNumber++ %></td>
                    <td><a href="javascript:loadPage('ViewPost.jsp?postNumber=<%= post.getPost_number() %>')"><%= post.getPost_title() %></a></td>
                    <td><%= post.getNumber_of_recommendations() %></td>
                    <td><%= post.getNumber_of_views() %></td>
                </tr>
            <%
                }
            %>
        </tbody>
    </table>
    <div class="write-btn">
        <button onclick="location.href='registeredPost.jsp'" target="contentFrame">글쓰기</button>
    	<button onclick="location.href='PostList.jsp'" target="contentFrame">목록</button>
    </div>
    <div class="pagination">
        <%
            int totalPosts = DB.getPostCountByMemberNumber(memberNumber);
            int totalPages = (int) Math.ceil(totalPosts / (double) postsPerPage);
            int pageDisplayCount = 3;

            int startPage = Math.max(currentPage - pageDisplayCount / 2, 1);
            int endPage = Math.min(startPage + pageDisplayCount - 1, totalPages);

            if (currentPage > 1) {
        %>
            <a href="MyPosts.jsp?page=<%= currentPage - 1 %>" target="contentFrame">이전</a>
        <%
            }
            for (int i = startPage; i <= endPage; i++) {
        %>
            <a href="MyPosts.jsp?page=<%= i %>" <%= (i == currentPage) ? "style='font-weight:bold;'" : "" %> target="contentFrame"><%= i %></a>
        <%
            }
            if (currentPage < totalPages) {
        %>
            <a href="MyPosts.jsp?page=<%= currentPage + 1 %>" target="contentFrame">다음</a>
        <%
            }
        %>
    </div>
</div>
<script>
    function loadPage(url) {
        var iframe = parent.document.getElementById('contentFrame');
        iframe.src = url;
    }
    
    function confirmDeleteAll() {
        if (confirm("정말 모든 게시물을 삭제하시겠습니까?")) {
            location.href = 'DeleteAllPosts.jsp';
        }
    }
</script>
<%DB.disconnect(); %>
</body>
</html>
