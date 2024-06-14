<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="Board.*,Service.*, java.util.List"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet"
	integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
	crossorigin="anonymous">
<link href="index.css" rel="stylesheet">
<title>Index Content</title>
<style>
.container {
	padding: 50px 0;
	display: flex;
	justify-content: space-between;
}

.section {
	width: 22%;
}

.section-title {
	font-size: 1.5em;
	border-bottom: 2px solid #007bff;
	padding-bottom: 10px;
	margin-bottom: 20px;
	text-align: center;
}

.list-group-item {
	font-size: 1em;
}

.list-group-item:last-child {
	border-bottom: none;
}
</style>
</head>
<body>
	<%
	request.setCharacterEncoding("UTF-8");
	DB.loadConnect();
	%>
	<div class="container">
		<div class="section">
			<h2 class="section-title">새로운 글</h2>
			<!-- 새로운 글 리스트 -->
			<div class="list-group">
				<%
				List<ProblemDTO> newProblems = DB.getNewProblems(5); // 최근 문제 5개 가져오기
				for (ProblemDTO problem : newProblems) {
				%>
				<a
					href="ViewProblem.jsp?problemNumber=<%=problem.getProblem_number()%>"
					class="list-group-item list-group-item-action"><%=problem.getProblem_title()%></a>
				<%
				}
				%>
				<a href="ProblemList.jsp" class="btn btn-primary mt-3">더보기</a>
			</div>
		</div>
		<div class="section">
			<h2 class="section-title">게시판</h2>
			<div class="list-group">
				<%
				List<PostDTO> postList = DB.getPosts(0, 5); // 최근 게시물 5개 가져오기
				for (int i = 0; i < postList.size(); i++) {
					PostDTO post = postList.get(i);
				%>
				<a href="ViewPost.jsp?postNumber=<%=post.getPost_number()%>"
					class="list-group-item list-group-item-action"><%=post.getPost_title()%></a>
				<%
				}
				%>
				<a href="PostList.jsp" class="btn btn-primary mt-3">더보기</a>
			</div>
		</div>
		<div class="section">
			<h2 class="section-title">인기글</h2>
			<!-- 인기글 리스트 -->
			<div class="list-group">
				<%
				List<ProblemDTO> popularProblems = DB.getPopularProblems(5); // 인기 문제 5개 가져오기
				for (ProblemDTO problem : popularProblems) {
				%>
				<a
					href="ViewProblem.jsp?problemNumber=<%=problem.getProblem_number()%>"
					class="list-group-item list-group-item-action"><%=problem.getProblem_title()%></a>
				<%
				}
				%>
				<a href="ProblemList.jsp" class="btn btn-primary mt-3">더보기</a>
			</div>
		</div>
		<div class="section">
			<h2 class="section-title">회원 랭킹</h2>
			<!-- 회원 랭킹 리스트 -->
			<div class="list-group">
				<%
				List<MemberDTO> memberList = DB.getMemberRanking();
				for (int i = 0; i < memberList.size(); i++) {
					MemberDTO member = memberList.get(i);
				%>
				<a href="#" class="list-group-item list-group-item-action"><%=i + 1%>.
					<%=member.getId()%> (<%=member.getLevelString()%>)</a>
				<%
				}
				%>
			</div>
		</div>
	</div>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
		integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
		crossorigin="anonymous"></script>
	<%
	DB.disconnect();
	%>
</body>
</html>
