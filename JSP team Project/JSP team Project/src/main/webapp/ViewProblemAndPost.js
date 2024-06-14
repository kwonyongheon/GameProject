function toggleCommentForm() {
    var form = document.getElementById('commentForm');
    form.style.display = form.style.display === 'none' ? 'block' : 'none';
    
    // form이 보이도록 스크롤 이동
    if (form.style.display === 'block') {
        form.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

function toggleReply(id) {
    var replyBox = document.getElementById(id);
    replyBox.style.display = replyBox.style.display === 'none' ? 'block' : 'none';

    // replyBox가 보이도록 스크롤 이동
    if (replyBox.style.display === 'block') {
        replyBox.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

function submitComment(event) {
    event.preventDefault();

    var commentContent = document.getElementById('comment_content').value;
    var xhr = new XMLHttpRequest();

    if (itemType === 'post') {
        xhr.open("POST", "Add/AddComment_post.jsp", true);
    } else if (itemType === 'problem') {
        xhr.open("POST", "Add/AddComment.jsp", true);
    }

    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            alert("댓글이 등록되었습니다.");
            location.reload();
        }
    };

    xhr.send(itemType + "Number=" + itemNumber + "&userComment=" + encodeURIComponent(commentContent));
}

function submitReply(event, commentNumber) {
    event.preventDefault();

    var replyContent = document.getElementById('reply_content_' + commentNumber).value;
    var xhr = new XMLHttpRequest();

    if (itemType === 'post') {
        xhr.open("POST", "Add/AddReply_post.jsp", true);
    } else if (itemType === 'problem') {
        xhr.open("POST", "Add/AddReply.jsp", true);
    }

    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            alert("답글이 등록되었습니다.");
            location.reload();
        }
    };

    xhr.send("commentNumber=" + commentNumber + "&replyContent=" + encodeURIComponent(replyContent));
}

function incrementLikes(commentId) {
    var xhr = new XMLHttpRequest();

    if (itemType === 'post') {
        xhr.open("POST", "Likes/IncrementLikes_post.jsp", true);
    } else if (itemType === 'problem') {
        xhr.open("POST", "Likes/IncrementLikes.jsp", true);
    }

    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            var responseText = xhr.responseText;
            alert(responseText);

            // 추천 수 업데이트
            var likes = document.getElementById('likes' + commentId);
            var likeBtn = document.getElementById('likeBtn' + commentId);
            var currentLikes = parseInt(likes.textContent);
            if (responseText.includes("완료")) {
                likes.textContent = currentLikes + 1;
                likeBtn.classList.add('active');
            } else if (responseText.includes("취소")) {
                likes.textContent = currentLikes - 1;
                likeBtn.classList.remove('active');
            }
        }
    };
    xhr.send("comment_id=" + commentId + "&type=comment");
}

function incrementLikesReply(replyId) {
    var xhr = new XMLHttpRequest();

    if (itemType === 'post') {
        xhr.open("POST", "Likes/IncrementLikesReply_post.jsp", true);
    } else if (itemType === 'problem') {
        xhr.open("POST", "Likes/IncrementLikesReply.jsp", true);
    }

    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            var responseText = xhr.responseText;
            alert(responseText);

            // 추천 수 업데이트
            var likes = document.getElementById('likesReply' + replyId);
            var likeBtn = document.getElementById('likeBtnReply' + replyId);
            var currentLikes = parseInt(likes.textContent);
            if (responseText.includes("완료")) {
                likes.textContent = currentLikes + 1;
                likeBtn.classList.add('active');
            } else if (responseText.includes("취소")) {
                likes.textContent = currentLikes - 1;
                likeBtn.classList.remove('active');
            }
        }
    };
    xhr.send("reply_id=" + replyId + "&type=reply");
}

function reportComment(commentId) {
    if (confirm("이 댓글을 신고하시겠습니까?")) {
        var xhr = new XMLHttpRequest();

        if (itemType === 'post') {
            xhr.open("POST", "Report/ReportComment_post.jsp", true);
        } else if (itemType === 'problem') {
            xhr.open("POST", "Report/ReportComment.jsp", true);
        }

        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                alert(xhr.responseText); // 서버에서 전송된 메시지를 그대로 표시
            }
        };
        xhr.send("comment_id=" + commentId);
    }
}

function reportReply(replyId) {
    if (confirm("이 답글을 신고하시겠습니까?")) {
        var xhr = new XMLHttpRequest();

        if (itemType === 'post') {
            xhr.open("POST", "Report/ReportReply_post.jsp", true);
        } else if (itemType === 'problem') {
            xhr.open("POST", "Report/ReportReply.jsp", true);
        }

        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                alert(xhr.responseText); // 서버에서 전송된 메시지를 그대로 표시
            }
        };
        xhr.send("reply_id=" + replyId);
    }
}

function deleteComment(commentNumber) {
    if (confirm("이 댓글을 삭제하시겠습니까?")) {
        var xhr = new XMLHttpRequest();

        if (itemType === 'post') {
            xhr.open("POST", "Delete/DeleteComment_post.jsp", true);
        } else if (itemType === 'problem') {
            xhr.open("POST", "Delete/DeleteComment.jsp", true);
        }

        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                if (response.status === "success") {
                    alert(response.message);
                    document.getElementById('comment' + commentNumber).remove();
                } else {
                    alert(response.message);
                }
            }
        };
        xhr.send("commentNumber=" + commentNumber);
    }
}

function deleteReply(replyNumber) {
    if (confirm("이 답글을 삭제하시겠습니까?")) {
        var xhr = new XMLHttpRequest();

        if (itemType === 'post') {
            xhr.open("POST", "Delete/DeleteReply_post.jsp", true);
        } else if (itemType === 'problem') {
            xhr.open("POST", "Delete/DeleteReply.jsp", true);
        }

        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                if (response.status === "success") {
                    alert(response.message);
                    document.getElementById('reply' + replyNumber).remove();
                } else {
                    alert(response.message);
                }
            }
        };
        xhr.send("replyNumber=" + replyNumber);
    }
}

function editComment(commentNumber) {
    var commentContentElement = document.getElementById('commentContent' + commentNumber);
    var originalContent = commentContentElement.textContent;

    var newContent = prompt("댓글을 수정하세요:", originalContent);
    if (newContent !== null) {
        var xhr = new XMLHttpRequest();

        if (itemType === 'post') {
            xhr.open("POST", "Edit/EditComment_post.jsp", true);
        } else if (itemType === 'problem') {
            xhr.open("POST", "Edit/EditComment.jsp", true);
        }

        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                alert("댓글이 수정되었습니다.");
                commentContentElement.textContent = newContent;
            }
        };
        xhr.send("commentNumber=" + commentNumber + "&newContent=" + encodeURIComponent(newContent));
    }
}

function editReply(replyNumber) {
    var replyContentElement = document.getElementById('replyContent' + replyNumber);
    var originalContent = replyContentElement.textContent;

    var newContent = prompt("답글을 수정하세요:", originalContent);
    if (newContent !== null) {
        var xhr = new XMLHttpRequest();

        if (itemType === 'post') {
            xhr.open("POST", "Edit/EditReply_post.jsp", true);
        } else if (itemType === 'problem') {
            xhr.open("POST", "Edit/EditReply.jsp", true);
        }

        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                alert("답글이 수정되었습니다.");
                replyContentElement.textContent = newContent;
            }
        };
        xhr.send("replyNumber=" + replyNumber + "&newContent=" + encodeURIComponent(newContent));
    }
}

function handleRecommend(postNumber, isOwnPost, alreadyRecommended) {
    isOwnPost = (isOwnPost === 'true');
    alreadyRecommended = (alreadyRecommended === 'true');

    if (isOwnPost) {
        alert("자신의 게시물에는 추천할 수 없습니다.");
        return;
    }
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "Likes/IncrementLikes_post_main.jsp", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            var responseText = xhr.responseText;
            alert(responseText);

            // 추천 수 업데이트
            var likes = document.getElementById('postLikes' + postNumber);
            var likeBtn = document.getElementById('recommendBtn' + postNumber);
            var currentLikes = parseInt(likes.textContent);
            if (responseText.includes("완료")) {
                likes.textContent = currentLikes + 1;
                likeBtn.classList.add('recommended');
            } else if (responseText.includes("취소")) {
                likes.textContent = currentLikes - 1;
                likeBtn.classList.remove('recommended');
            }
        }
    };
    xhr.send("post_number=" + postNumber);
}

function handleRecommend_problem(problemNumber, isOwnPost, alreadyRecommended) {
    isOwnPost = (isOwnPost === 'true');
    alreadyRecommended = (alreadyRecommended === 'true');

    if (isOwnPost) {
        alert("자신의 문제에는 추천할 수 없습니다.");
        return;
    }
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "Likes/IncrementLikes_problem_main.jsp", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            var responseText = xhr.responseText;
            alert(responseText);

            // 추천 수 업데이트
            var likes = document.getElementById('postLikes' + problemNumber);
            var likeBtn = document.getElementById('recommendBtn' + problemNumber);
            var currentLikes = parseInt(likes.textContent);
            if (responseText.includes("완료")) {
                likes.textContent = currentLikes + 1;
                likeBtn.classList.add('recommended');
            } else if (responseText.includes("취소")) {
                likes.textContent = currentLikes - 1;
                likeBtn.classList.remove('recommended');
            }
        }
    };
    xhr.send("problem_number=" + problemNumber);
}

function confirmDelete(postNumber) {
    if (confirm("이 게시물을 삭제하시겠습니까?")) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "Delete/DeletePost.jsp", true);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                if (response.status === "success") {
                    alert(response.message);
                    window.location.href = 'PostList.jsp';
                } else {
                    alert(response.message);
                }
            }
        };
        xhr.send("postNumber=" + postNumber);
    }
}

function confirmDelete_problem(problemNumber) {
    if (confirm("이 문제를 삭제하시겠습니까?")) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "Delete/DeleteProblem.jsp", true);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
                if (response.status === "success") {
                    alert(response.message);
                    window.location.href = 'ProblemList.jsp';
                } else {
                    alert(response.message);
                }
            }
        };
        xhr.send("problemNumber=" + problemNumber);
    }
}
