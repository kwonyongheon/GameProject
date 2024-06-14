<%@ page language="java" contentType="text/html; charset=UTF-8"
   pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="registeredPost.css" rel="stylesheet">
<title>문제 출제</title>
</head>
<body>
   <%
   request.setCharacterEncoding("UTF-8");
   session = request.getSession();
   Integer memberNumber = (Integer) session.getAttribute("membership_number");
   if (memberNumber == null) {
      response.sendRedirect("LoginForm.html");
      return;
   }
   %>
   <div class="container">
      <form action="/JSP_team_Project/problemUpload" method="post"
         enctype="multipart/form-data">
         <h2 style="text-align: center; margin-bottom: 20px;">문제 출제</h2>
         <div class="form-group">
            <label class="header" for="problem_title">제목</label> <input type="text"
               id="problem_title" placeholder="제목을 입력하세요" name="title" required>
         </div>
         <div class="form-group">
            <label class="header" for="problem_content">내용</label>
            <textarea id="problem_content" placeholder="내용을 입력하세요" name="content"
               rows="6" required></textarea>
         </div>
         <div class="form-group">
            <label class="header" for="problem_category">카테고리</label> 
            <input type="text" id="problem_category" placeholder="카테고리를 입력하세요" name="category" required>
         </div>
         <div class="form-group">
            <label class="header" for="correct_answer">정답</label> 
            <textarea id="correct_answer" placeholder="정답을 입력하세요" name="correct_answer"
               rows="2" required></textarea>
         </div>
         <div class="form-group">
            <label class="header" for="solution_process">해결 과정</label> 
            <textarea id="solution_process" placeholder="해결 과정을 입력하세요" name="solution_process"
               rows="4" required></textarea>
         </div>
         <div class="form-group file-upload">
            <label class="header" for="file">파일 업로드</label> <input type="file"
               id="file" name="file">
         </div>
         <input type="submit" value="등록">
      </form>
   </div>
</body>
</html>