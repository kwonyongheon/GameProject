<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*, Service.DB, Board.PostDTO"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="PostAndProblemList.css" rel="stylesheet">
<title>게시판</title>
</head>
<body>
	<div class="container">
		<h2 align="center">전체 게시물</h2>
		<%
		// 세션에서 로그인한 사용자 정보 가져오기
		request.setCharacterEncoding("UTF-8");
		DB.loadConnect();
		session = request.getSession();
		Integer memberNumber = (Integer) session.getAttribute("membership_number");

		int currentPage = 1;
		int postsPerPage = 10;
		if (request.getParameter("page") != null) {
			currentPage = Integer.parseInt(request.getParameter("page"));
		}
		int startPost = (currentPage - 1) * postsPerPage;
		List<PostDTO> postList = DB.getPosts(startPost, postsPerPage);
		%>
		<table>
			<thead>
				<tr class="header">
					<th class="num">번호</th>
					<th class="title">제목</th>
					<th>작성자</th>
					<th>추천수</th>
					<th>조회수</th>
				</tr>
			</thead>
			<tbody>
				<%
				int displayNumber = startPost + 1;
				for (PostDTO post : postList) {
				%>
				<tr>
					<td><%=displayNumber++%></td>
					<td><a
						href="javascript:loadPage('ViewPost.jsp?postNumber=<%=post.getPost_number()%>')"><%=post.getPost_title()%></a></td>
					<td><%=post.getMember_id()%></td>
					<td><%=post.getNumber_of_recommendations()%></td>
					<td><%=post.getNumber_of_views()%></td>
				</tr>
				<%
				}
				%>
			</tbody>
		</table>
		<div class="write-btn">
			<%
			if (memberNumber != null) {
			%>
			<button onclick="checkLoginAndRedirect('registeredPost.jsp')">글쓰기</button>
			<button onclick="checkLoginAndRedirect('MyPosts.jsp')">내 게시물</button>
			<%
			} else {
			%>
			<button onclick="checkLoginAndRedirect('PostList.jsp')">글쓰기</button>
			<button onclick="checkLoginAndRedirect('PostList.jsp')">내 게시물</button>
			<%
			}
			%>
		</div>
		<div class="pagination">
			<%
			int totalPosts = DB.getPostCount();
			int totalPages = (int) Math.ceil(totalPosts / (double) postsPerPage);
			int pageDisplayCount = 3;

			int startPage = Math.max(currentPage - pageDisplayCount / 2, 1);
			int endPage = Math.min(startPage + pageDisplayCount - 1, totalPages);

			if (currentPage > 1) {
			%>
			<a
				href="javascript:loadPage('PostList.jsp?page=<%=currentPage - 1%>')">이전</a>
			<%
			}
			for (int i = startPage; i <= endPage; i++) {
			%>
			<a href="javascript:loadPage('PostList.jsp?page=<%=i%>')"
				<%=(i == currentPage) ? "style='font-weight:bold;'" : ""%>><%=i%></a>
			<%
			}
			if (currentPage < totalPages) {
			%>
			<a
				href="javascript:loadPage('PostList.jsp?page=<%=currentPage + 1%>')">다음</a>
			<%
			}
			%>
		</div>
	</div>
	<script>
		function checkLoginAndRedirect(url) {
	    	if (<%= memberNumber == null %>) {
	        	alert('로그인이 필요합니다.');
	        	loadPage(url);
	    	} else {
	    		loadPage(url);
	    	}
		}
	
		function loadPage(url) {
			var iframe = parent.document.getElementById('contentFrame');
			iframe.src = url;
		}
	</script>
</body>
<%
DB.disconnect();
%>
</html>
