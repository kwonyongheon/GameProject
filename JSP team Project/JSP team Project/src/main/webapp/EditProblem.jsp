<%@ page import="java.util.*, Board.*, Service.*"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>게시물 수정</title>
<style>
html, body {
	margin: 0;
	padding: 0;
	overflow: hidden;
	height: 100%;
	width: 100%;
}

body {
	font-family: Arial, sans-serif;
	margin: 0;
	padding: 0;
}

.container {
	width: 80%;
	margin: 20px auto;
	background-color: #fff;
	padding: 20px;
	box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
	border-radius: 8px;
	position: relative;
}

h2 {
	color: #333;
	margin-bottom: 10px;
}

label {
	display: block;
	color: #666;
	margin: 10px 0 5px;
}

input[type="text"], textarea {
	width: 100%;
	padding: 10px;
	border: 1px solid #ddd;
	border-radius: 5px;
	box-sizing: border-box;
}

.submit-btn {
	background-color: #4CAF50;
	color: white;
	padding: 10px 20px;
	border: none;
	border-radius: 5px;
	cursor: pointer;
	margin-top: 10px;
}

.submit-btn:hover {
	background-color: #45a049;
}
</style>
</head>
<body>
	<div class="container">
		<%
		request.setCharacterEncoding("UTF-8");
		DB.loadConnect();
		int problemNumber = Integer.parseInt(request.getParameter("problem_number"));
		ProblemDTO problem = DB.getProblem(problemNumber);

		if (problem != null) {
		%>
		<h2>문제 수정</h2>
		<form method="post" action="EditProblem_process.jsp">
			<input type="hidden" name="problem_number"
				value="<%=problem.getProblem_number()%>"> <label
				for="problem_title">제목</label> <input type="text" id="problem_title"
				name="problem_title" value="<%=problem.getProblem_title()%>"
				required> <label for="problem_content">내용</label>
			<textarea id="problem_content" name="problem_content" rows="10"
				required><%=problem.getProblem_content()%></textarea>
			<label for="correct_answer">정답</label> <input type="text"
				id="correct_answer" name="correct_answer"
				value="<%=problem.getCorrect_answer()%>" required> 
			<label for="solution_process">풀이과정</label> <input type="text" 
				id="solution_process"name="solution_process"
				value="<%=problem.getSolution_process()%>" required>
			<button type="submit" class="submit-btn">수정 완료</button>
		</form>
		<%
		} else {
		out.println("<p>해당 글을 찾을 수 없습니다.</p>");
		}
		DB.disconnect();
		%>
	</div>
</body>
</html>