<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page
    import="java.sql.*,java.util.*, java.text.SimpleDateFormat, java.sql.SQLException, java.io.IOException, javax.servlet.ServletException"%>
<%@ page import="Board.*, answer.*, Service.*"%>
<%@ page import="WebServlet.PostFileUploadServlet"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" type="text/css" href="ViewProblemAndPost.css">
<title>ViewProblem</title>
</head>
<body>
    <div class="container">
        <%
        request.setCharacterEncoding("UTF-8");
        DB.loadConnect();
        int problemNumber = Integer.parseInt(request.getParameter("problemNumber"));
        ProblemDTO problem = DB.getProblem(problemNumber); 

        session = request.getSession();
        Integer loggedInMemberNumber = (Integer) session.getAttribute("membership_number");
        String id = null;
        
        if (loggedInMemberNumber != null) {
            ResultSet rs = DB.FindByMembership_number(loggedInMemberNumber);
            if(rs.next()){
            id = rs.getString("ID");
            }
        }
        
        if (problem != null) {
            DB.incrementProblemViews(problemNumber);
            boolean isAuthor = (loggedInMemberNumber != null && loggedInMemberNumber == problem.getMembership_number());
        %>
        <div class="post-header">
            <div class="post-meta">
                <span class="post-author">작성자: <%=problem.getMember_id()%></span>
                <div class="post-stats">
                    <span class="post-views">조회수: <%=problem.getNumber_of_views()%></span>
                    <span class="post-recommendations">추천수: <span
                        id="postLikes<%=problemNumber%>"><%=problem.getNumber_of_likes()%></span></span>
                </div>
            </div>
        </div>
        <hr>
        <div class="post-title">
            <h2><%=problem.getProblem_title()%></h2>
        </div>
        <div class="post-content">
            <%
            ResultSet rs = DB.getAttachedProblemFiles(problemNumber);
            while (rs.next()) {
                    String fileName = rs.getString("attached_file_name");
                    String imageUrl = "fileSave/" + fileName;
                    String fileExtension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
                    if (Arrays.asList("jpg", "jpeg", "png", "gif").contains(fileExtension)) {
            %>
            <img src="<%=imageUrl%>" alt="첨부된 이미지">
            <%
            }
            
            }
            %>
            <p><%=problem.getProblem_content()%></p>
        </div>

        <div class="recommend-btn-container">
            <%
            boolean alreadyRecommended = false;
            if (loggedInMemberNumber != null) {
                alreadyRecommended = DB.isProblemRecommendedByUser(problemNumber, loggedInMemberNumber);
            }
            %>
            <button id="recommendBtn<%=problemNumber%>"
                class="recommend-btn <%=alreadyRecommended ? "recommended" : ""%>"
                onclick="handleRecommend_problem(<%=problemNumber%>, '<%=isAuthor%>', '<%=alreadyRecommended%>')">추천</button>
        </div>
        <div class="button-group">
            <a href="ProblemList.jsp" class="back-btn button">목록</a>
            <%
            if (isAuthor) {
            %>
            <a href="EditProblem.jsp?problem_number=<%=problem.getProblem_number()%>"
                class="edit1-btn button">수정</a>
            <button class="delete1-btn button"
                onclick="confirmDelete_problem(<%=problem.getProblem_number()%>)">삭제</button>
            <%
            }
            %>
        </div>
        
        <div class="answer-section">
            <textarea id="answerTextarea" placeholder="정답을 입력하세요"></textarea>
            <button class="button" onclick="checkAnswer(<%=problemNumber%>)">채점</button>
            <button class="button" id="explanationBtn" style="display:none;" onclick="showExplanation()">정답보기</button>
            <div id="explanation" style="display:none;">
                <p>해설 : <%=problem.getSolution_process()%> 정답 : <%=problem.getCorrect_answer() %></p>
            </div>
        </div>
        <%
        } else {
        out.println("<p>해당 글을 찾을 수 없습니다.</p>");
        }
        %>
    </div>
    <div class="container">
        <div class="comment-container">
            <div class="comment-header">
                <h2>댓글</h2>
                <%
                if (loggedInMemberNumber != null) {
                %>
                <button onclick="toggleCommentForm()">댓글작성</button>
                <%
                } else {
                %>
                <button onclick="alert('로그인 후 이용하세요.');">댓글 작성</button>
                <%
                }
                %>
            </div>
            <div id="commentForm" style="display: none;">
                <p class="comment-body">
                    <strong><%=id%></strong>
                </p>
                <form onsubmit="submitComment(event)">
                    <textarea id="comment_content" name="comment_content"
                        placeholder="댓글을 입력하세요."></textarea>
                    <button type="submit">등록</button>
                </form>
            </div>
            <div id="commentList">
                <%
                List<Comment> comments = null;

                comments = DB.getProblemComments(problemNumber);

                if (comments != null) {
                    for (Comment comment : comments) {
                        int commentNumber = comment.getCommentNumber();
                        int commentMemberNumber = comment.getMemberNumber();
                        boolean liked = false;

                        if (loggedInMemberNumber != null) {

                    liked = DB.isCommentLiked(commentNumber, loggedInMemberNumber);

                        }
                %>
                <div class="comment" id="comment<%=commentNumber%>">
                    <p class="comment-body">
                        <strong><%=comment.getMemberId()%></strong>
                    </p>
                    <p id="commentContent<%=commentNumber%>"><%=comment.getContent()%></p>
                    <div class="comment-meta">
                        <span><%=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(comment.getWritingTime())%></span>
                        <div class="comment-buttons">
                            <button class="report-btn"
                                onclick="reportComment(<%=commentNumber%>, 'comment')">신고</button>
                            <button class="reply-btn"
                                onclick="toggleReply('replyForm<%=commentNumber%>')">답글작성</button>
                            <button class="like-btn <%=liked ? "active" : ""%>"
                                id="likeBtn<%=commentNumber%>"
                                onclick="incrementLikes(<%=commentNumber%>)">
                                추천<span id="likes<%=commentNumber%>"><%=comment.getRecommendations()%></span>
                            </button>
                            <%
                            if (loggedInMemberNumber != null && commentMemberNumber == loggedInMemberNumber) {
                            %>
                            <button class="edit-btn"
                                onclick="editComment(<%=commentNumber%>)">수정</button>
                            <button class="delete-btn"
                                onclick="deleteComment(<%=commentNumber%>)">삭제</button>
                            <%
                            }
                            %>
                        </div>
                    </div>
                    <div id="replyForm<%=commentNumber%>" style="display: none;">
                        <form onsubmit="submitReply(event, <%=commentNumber%>)">
                            <textarea id="reply_content_<%=commentNumber%>"
                                placeholder="답글을 입력하세요."></textarea>
                            <button type="submit">등록</button>
                        </form>
                    </div>
                    <div id="reply<%=commentNumber%>" class="nested-comment">
                        <%
                        List<Reply> replies = null;

                        replies = DB.getProblemReplies(commentNumber);

                        if (replies != null) {
                            for (Reply reply : replies) {
                                int replyNumber = reply.getReplyNumber();
                                int replyMemberNumber = reply.getMemberNumber();
                                boolean replyLiked = false;

                                if (loggedInMemberNumber != null) {

                            replyLiked = DB.isReplyLiked(replyNumber, loggedInMemberNumber);

                                }
                        %>
                        <div class="reply" id="reply<%=replyNumber%>">
                            <p class="comment-body">
                                <strong><%=reply.getMemberId()%></strong>
                            </p>
                            <p id="replyContent<%=replyNumber%>"><%=reply.getContent()%></p>
                            <div class="comment-meta">
                                <span><%=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(reply.getWritingTime())%></span>
                                <div class="comment-buttons">
                                    <button class="report-btn"
                                        onclick="reportReply(<%=replyNumber%>, 'reply')">신고</button>
                                    <button class="like-btn <%=replyLiked ? "active" : ""%>"
                                        id="likeBtnReply<%=replyNumber%>"
                                        onclick="incrementLikesReply(<%=replyNumber%>)">
                                        추천<span id="likesReply<%=replyNumber%>"><%=reply.getRecommendations()%></span>
                                    </button>
                                    <%
                                    if (loggedInMemberNumber != null && replyMemberNumber == loggedInMemberNumber) {
                                    %>
                                    <button class="edit-btn"
                                        onclick="editReply(<%=replyNumber%>)">수정</button>
                                    <button class="delete-btn"
                                        onclick="deleteReply(<%=replyNumber%>)">삭제</button>
                                    <%
                                    }
                                    %>
                                </div>
                            </div>
                        </div>
                        <%
                        }
                        }
                        %>
                    </div>
                </div>
                <%
                }
                }
                %>
            </div>
        </div>
    </div>
</body>
<script>
    var itemType = 'problem';
    var itemNumber = '<%=request.getParameter("problemNumber")%>';

    function checkAnswer(problemNumber) {
        var answer = document.getElementById("answerTextarea").value;

        // 서버에 정답 확인을 요청하는 비동기 통신
        fetch('CheckAnswerServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: 'problemNumber=' + problemNumber + '&answer=' + encodeURIComponent(answer)
        })
        .then(response => response.text())
        .then(result => {
            if (result == 'correct') {
                alert('정답입니다!');
            } else {
                alert('오답입니다');
                document.getElementById('explanationBtn').style.display = 'inline';
            }
        })
        .catch(error => console.error('Error:', error));
    }

    function showExplanation() {
        document.getElementById('explanation').style.display = 'block';
    }
</script>
<script src="ViewProblemAndPost.js"></script>
<%
DB.disconnect();
%>
</html>
