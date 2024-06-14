<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.sql.*, Service.* ,WebServlet.*"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet"
	integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
	crossorigin="anonymous">
<link href="index.css" rel="stylesheet">
<title>전자문제집</title>
</head>
<body>
	<%
	request.setCharacterEncoding("UTF-8");
	DB.loadConnect();
	Integer membership_number = (Integer) session.getAttribute("membership_number");
	String ID = null;
	String permission = null;
	if (membership_number != null) { // null 체크 추가
		ResultSet rs = DB.FindByMembership_number(membership_number);
		if (rs.next()) {
			ID = rs.getString("ID");
			permission = rs.getString("permission");
		}
	}
	%>

	<div class="d-flex-wrapper">
		<nav
			class="navbar navbar-expand-lg navbar-light bg-light border-bottom">
			<div class="container-fluid ms-5">
				<a class="navbar-brand" href="javascript:void(0);"
					onclick="goToIndex();"><img src="SK_inside2.png"
					style="display: inline-block;"></a>
				<h1 style="display: inline-block;">
					<a href="javascript:void(0);" onclick="goToIndex();">SK_Inside.com</a>
				</h1>
				<div
					class="collapse navbar-collapse d-flex justify-content-end me-3"
					id="navbarNav">
					<%
					if (membership_number != null && permission != null && permission.equals("회원")) {
					%>
					<div
						class="position-absolute top-50 start-50 translate-middle fs-3"><%=ID%>님
						안녕하세요 행복하세요
					</div>
					<div>
						<a class="LoginJoin" href="LogOut.jsp">로그아웃</a>
					</div>
					<%
					} else if (permission != null && permission.equals("관리자")) {
					%>
					<div
						class="position-absolute top-50 start-50 translate-middle fs-3"><%=ID%>
						관리자님으로 로그인되었습니다.
					</div>
					<div>
						<a class="LoginJoin" href="LogOut.jsp">로그아웃</a>
					</div>
					<%
					} else {
					%>
					<div>
						<a class="LoginJoin" href="LoginForm.html">회원가입|로그인</a>
					</div>
					<%
					}
					%>
				</div>
			</div>
		</nav>
		<nav class="navbar navbar-expand-lg bg-body-tertiary">
			<div class="container-fluid">
				<div class="dropdown me-3">
					<button class="btn btn-secondary dropdown-toggle" type="button"
						data-bs-toggle="dropdown" aria-expanded="false">메뉴</button>
					<ul class="dropdown-menu">
						<li><a class="dropdown-item" onclick="registeredProblem()">문제출제</a></li>
						<li><a class="dropdown-item" onclick="registeredPost()">게시글
								등록</a></li>
						<li><a class="dropdown-item" onclick="MyWriting()">내가 쓴글</a></li>
					</ul>
				</div>
				<div class="collapse navbar-collapse" id="navbarSupportedContent">
					<ul class="navbar-nav me-auto mb-2 mb-lg-0">
						<li class="nav-item dropdown"><a
							class="nav-link dropdown-toggle" href="#" role="button"
							data-bs-toggle="dropdown" aria-expanded="false">문제</a>
							<ul class="dropdown-menu">
								<li><a class="dropdown-item" onclick="ProblemList()">등록된
										문제</a></li>
								<li><hr class="dropdown-divider"></li>
								<li><a class="dropdown-item" onclick="registeredProblem()">문제
										등록</a></li>
							</ul></li>
						<li class="nav-item dropdown"><a
							class="nav-link dropdown-toggle" href="#" role="button"
							data-bs-toggle="dropdown" aria-expanded="false">게시판</a>
							<ul class="dropdown-menu">
								<li><a class="dropdown-item" onclick="PostList()">게시글
										보기</a></li>
								<li><hr class="dropdown-divider"></li>
								<li><a class="dropdown-item" onclick="registeredPost()">게시글
										작성</a></li>
							</ul></li>
						<li class="nav-item"><a class="nav-link"
							onclick="MemberInfo()">회원정보</a></li>
						<li class="nav-item"><a class="nav-link" onclick="inquiry()">문의하기</a>
						</li>
						<li class="nav-item"><a class="nav-link" onclick="mailBox()">받은편지함</a></li>
						<%
						if (permission != null && permission.equals("관리자")) {
						%>
						<li class="nav-item dropdown"><a
							class="nav-link dropdown-toggle" href="#" role="button"
							data-bs-toggle="dropdown" aria-expanded="false">관리자메뉴</a>
							<ul class="dropdown-menu">
								<li><a class="dropdown-item" onclick="Show_All_report()">신고접수현황</a></li>
								<li><hr class="dropdown-divider"></li>
								<li><a class="dropdown-item" onclick="inquiry_list()">회원 문의 내역</a></li>
							</ul></li>
						<%
						}
						%>
					</ul>
					<form class="d-flex" role="search">
						<input class="form-control me-2" type="search"
							placeholder="Search" aria-label="Search">
						<button class="btn btn-outline-success" type="submit">Search</button>
					</form>
				</div>
			</div>
		</nav>

		<!--  index.jsp 에서 기본 컨텐트 내용 -->
		<iframe id="contentFrame" src=content.jsp width="100%" height="500px"></iframe>

		<footer class="py-3 bg-dark mt-auto">
			<div class="container">
				<p class="m-0 text-center text-white">Copyright &copy; HS 2024</p>
			</div>
		</footer>
	</div>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
		integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
		crossorigin="anonymous"></script>
	<script>
		//회원정보 클릭시 MemberInfo.jsp 내용 iframe태그로 표현
		function MemberInfo() {
			var xhr = new XMLHttpRequest();
			xhr.open('GET', 'CheckSessionServlet', true);
			xhr.onreadystatechange = function() {
				if (xhr.readyState === 4 && xhr.status === 200) {
					var response = xhr.responseText;
					if (response === 'true') {
						var iframe = document.getElementById('contentFrame');
						iframe.src = 'MemberInfo.jsp';
					} else {
						alert("로그인 후 이용해주세요");
						window.location.href = 'LoginForm.html';
					}
				}
			};
			xhr.send();
		}

		//문의하기 클릭시 inquiry.jsp 내용 iframe태그로 표현
		function inquiry() {
			var xhr = new XMLHttpRequest();
			xhr.open('GET', 'CheckSessionServlet', true);
			xhr.onreadystatechange = function() {
				if (xhr.readyState === 4 && xhr.status === 200) {
					var response = xhr.responseText;
					if (response === 'true') {
						var iframe = document.getElementById('contentFrame');
						iframe.src = 'inquiry.jsp';
					} else {
						alert("로그인 후 이용해주세요");
						window.location.href = 'LoginForm.html';
					}
				}
			};
			xhr.send();
		}

		//받은편지함 클릭시 mailBox.jsp 내용 iframe태그로 표현
		function mailBox() {
			var xhr = new XMLHttpRequest();
			xhr.open('GET', 'CheckSessionServlet', true);
			xhr.onreadystatechange = function() {
				if (xhr.readyState === 4 && xhr.status === 200) {
					var response = xhr.responseText;
					if (response === 'true') {
						var iframe = document.getElementById('contentFrame');
						iframe.src = 'mailBox.jsp';
					} else {
						alert("로그인 후 이용해주세요");
						window.location.href = 'LoginForm.html';
					}
				}
			};
			xhr.send();
		}

		//문제 등록 클릭시 registeredProblem.jsp 내용 iframe태그로 표현
		function registeredProblem() {
			var xhr = new XMLHttpRequest();
			xhr.open('GET', 'CheckSessionServlet', true);
			xhr.onreadystatechange = function() {
				if (xhr.readyState === 4 && xhr.status === 200) {
					var response = xhr.responseText;
					if (response === 'true') {
						var iframe = document.getElementById('contentFrame');
						iframe.src = 'WriteProblem.jsp';
					} else {
						alert("로그인 후 이용해주세요");
						window.location.href = 'LoginForm.html';
					}
				}
			};
			xhr.send();
		}

		//게시글 작성 클릭시 registeredPost.jsp 내용 iframe태그로 표현
		function registeredPost() {
			var xhr = new XMLHttpRequest();
			xhr.open('GET', 'CheckSessionServlet', true);
			xhr.onreadystatechange = function() {
				if (xhr.readyState === 4 && xhr.status === 200) {
					var response = xhr.responseText;
					if (response === 'true') {
						var iframe = document.getElementById('contentFrame');
						iframe.src = 'registeredPost.jsp';
					} else {
						alert("로그인 후 이용해주세요");
						window.location.href = 'LoginForm.html';
					}
				}
			};
			xhr.send();
		}

		//내가 쓴글 클릭시 MyWriting.jsp 내용 iframe태그로 표현
		function MyWriting() {
			var xhr = new XMLHttpRequest();
			xhr.open('GET', 'CheckSessionServlet', true);
			xhr.onreadystatechange = function() {
				if (xhr.readyState === 4 && xhr.status === 200) {
					var response = xhr.responseText;
					if (response === 'true') {
						var iframe = document.getElementById('contentFrame');
						iframe.src = 'MyWriting.jsp';
					} else {
						alert("로그인 후 이용해주세요");
						window.location.href = 'LoginForm.html';
					}
				}
			};
			xhr.send();
		}

		//등록된 문제 클릭시 ProblemList.jsp 내용 iframe태그로 표현
		function ProblemList() {
			var iframe = document.getElementById('contentFrame');
			iframe.src = 'ProblemList.jsp';
		}

		//게시글 보기 클릭시 PostList.jsp 내용 iframe태그로 표현
		function PostList() {
			var iframe = document.getElementById('contentFrame');
			iframe.src = 'PostList.jsp';
		}
		
		//회원 문의 내역 클릭시 inquiry_list.jsp 내용 iframe태그로 표현
		function inquiry_list() {
			var iframe = document.getElementById('contentFrame');
			iframe.src = 'inquiry_list.jsp';
		}
		
		// 관리자페이지 신고연결
	      function Show_All_report() {
	         var iframe = document.getElementById('contentFrame');
	         iframe.src = 'Show_All_report.jsp';
	      }

		//로고 클릭시 히스토리 삭제
		function goToIndex() {
			window.location.replace('index.jsp');
		}

		// 자바스크립트로 iframe 높이를 동적으로 조정하는 함수
		function resizeIframe() {
			var iframe = document.getElementById('contentFrame');
			iframe.style.height = iframe.contentWindow.document.body.scrollHeight
					+ 'px';
		}

		// iframe 로드 후 높이 조정
		document.getElementById('contentFrame').onload = resizeIframe;
	</script>
	<%DB.disconnect(); %>
</body>
</html>
