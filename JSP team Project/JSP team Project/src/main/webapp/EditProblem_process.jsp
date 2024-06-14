<%@ page import="java.util.*, Board.*, Service.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>문제 수정 완료</title>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    DB.loadConnect();
    // 파라미터로부터 게시물 번호, 제목, 내용 가져오기
    int problemNumber = Integer.parseInt(request.getParameter("problem_number"));
    String problemTitle = request.getParameter("problem_title");
    String problemContent = request.getParameter("problem_content");
    String correctAnswer = request.getParameter("correct_answer");
    String solutionProcess = request.getParameter("solution_process");

    // 게시물 수정 메서드 호출
    DB.updateProblem(problemNumber, problemTitle, problemContent, correctAnswer, solutionProcess);
    DB.disconnect();
%>
    <script>
        alert("게시물이 성공적으로 수정되었습니다.");
        window.location.href = "ProblemList.jsp";
    </script>
</body>
</html>
