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
<title>ViewPost</title>
</head>
<body>
	<div class="container">
		<%
		request.setCharacterEncoding("UTF-8");
		DB.loadConnect();
		int postNumber = Integer.parseInt(request.getParameter("postNumber"));
		PostDTO post = DB.getPost(postNumber);

		session = request.getSession();
		Integer loggedInMemberNumber = (Integer) session.getAttribute("membership_number");
		String id = null;
		
		if (loggedInMemberNumber != null) {
			ResultSet rs = DB.FindByMembership_number(loggedInMemberNumber);
			if(rs.next()){
			id = rs.getString("ID");
			}
	    }
		
		if (post != null) {
			DB.incrementViews(postNumber);
			boolean isAuthor = (loggedInMemberNumber != null && loggedInMemberNumber == post.getMember_number());
		%>
		<div class="post-header">
			<div class="post-meta">
				<span class="post-author">작성자: <%=post.getMember_id()%></span>
				<div class="post-stats">
					<span class="post-views">조회수: <%=post.getNumber_of_views()%></span>
					<span class="post-recommendations">추천수: <span
						id="postLikes<%=postNumber%>"><%=post.getNumber_of_recommendations()%></span></span>
				</div>
			</div>
		</div>
		<hr>
		<div class="post-title">
			<h2><%=post.getPost_title()%></h2>
		</div>
		<div class="post-content">
			<%
			ResultSet rs = DB.getAttachedFiles(postNumber);
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
			<p><%=post.getPost_content()%></p>
		</div>
		<div class="recommend-btn-container">
			<%
			boolean alreadyRecommended = false;
			if (loggedInMemberNumber != null) {
				alreadyRecommended = DB.isPostRecommendedByUser(postNumber, loggedInMemberNumber);
			}
			%>
			<button id="recommendBtn<%=postNumber%>"
				class="recommend-btn <%=alreadyRecommended ? "recommended" : ""%>"
				onclick="handleRecommend(<%=postNumber%>, '<%=isAuthor%>', '<%=alreadyRecommended%>')">추천</button>
		</div>
		<div class="button-group">
			<a href="PostList.jsp" class="back-btn button">목록</a>
			<%
			if (isAuthor) {
			%>
			<a href="EditPost.jsp?post_number=<%=post.getPost_number()%>"
				class="edit1-btn button">수정</a>
			<button class="delete1-btn button"
				onclick="confirmDelete(<%=post.getPost_number()%>)">삭제</button>
			<%
			}
			%>
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

				comments = DB.getPostComments(postNumber);

				if (comments != null) {
					for (Comment comment : comments) {
						int commentNumber = comment.getCommentNumber();
						int commentMemberNumber = comment.getMemberNumber();
						boolean liked = false;

						if (loggedInMemberNumber != null) {

					liked = DB.isPostCommentLiked(commentNumber, loggedInMemberNumber);

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

						replies = DB.getPostReplies(commentNumber);

						if (replies != null) {
							for (Reply reply : replies) {
								int replyNumber = reply.getReplyNumber();
								int replyMemberNumber = reply.getMemberNumber();
								boolean replyLiked = false;

								if (loggedInMemberNumber != null) {

							replyLiked = DB.isPostReplyLiked(replyNumber, loggedInMemberNumber);

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
        var itemType = 'post';
        var itemNumber = '<%=request.getParameter("postNumber")%>';
</script>
<script src="ViewProblemAndPost.js"></script>
<%
DB.disconnect();
%>
</html>
