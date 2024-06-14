<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.sql.*, Service.*"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet"
	integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
	crossorigin="anonymous">
<link href="index.css" rel="stylesheet">
<style>
html, body {
	margin: 0;
	padding: 0;
	overflow: hidden;
	height: 100%;
	width: 100%;
}

.table {
	width: 100%;
	height: auto;
}

.form-control {
	width: 25% !important;
}
</style>
<title>MemberInfo</title>
</head>
<body>
	<%
	request.setCharacterEncoding("UTF-8");
	DB.loadConnect();
	Integer membership_number = (Integer) session.getAttribute("membership_number");
	if (membership_number == null) {
		response.sendRedirect("LoginForm.html");
		return;
	}
	ResultSet rs = DB.FindByMembership_number(membership_number);
	String ID = null;
	String nickname = null;
	String name = null;
	String gender = null;
	String phone_number = null;
	String level = null;
	String email = null;
	String permission = null;

	if (rs.next()) {
		ID = rs.getString("ID");
		nickname = rs.getString("nickname");
		name = rs.getString("name");
		gender = rs.getString("gender");
		phone_number = rs.getString("phone_number");
		level = rs.getString("level");
		email = rs.getString("email");
		permission = rs.getString("permission");
	} else {
		out.println("<script>alert('세션이 만료되었습니다. 로그인 페이지로 이동합니다.'); location.href='LoginForm.html';</script>");
	}

	if (level.equals("D")) {
		level = "아이언";
	} else if (level.equals("C")) {
		level = "브론즈";
	} else if (level.equals("B")) {
		level = "실버";
	} else if (level.equals("A")) {
		level = "골드";
	} else {
		level = "관리자에게 문의하세요.";
	}

	if (phone_number == null) {
		phone_number = "전화번호를 입력하세요.";
	}

	if (email == null) {
		email = "이메일을 입력하세요.";
	}
	%>
	<div class="container">
		<table class="table m-5 table-bordered">
			<thead class="table-primary">
				<tr>
					<th>항목</th>
					<th>내용</th>
				</tr>
			</thead>
			<tbody class="table-group-divider">
				<tr>
					<td>ID</td>
					<td>
						<form action="editID.jsp" method="post"
							class="d-flex align-items-center">
							<input type="text" id="ID" name="ID" placeholder="<%=ID%>"
								class="form-control me-3" required>
							<button type="submit" class="btn btn-primary">변경</button>
						</form>
					</td>
				</tr>
				<tr>
					<td>Password</td>
					<td>
						<form action="editPW.jsp" method="post"
							class="d-flex flex-column align-items-center">
							<div class="mb-3 w-100">
								<label for="oldPassword" class="form-label me-3">현재 비밀번호
									입력</label> <input type="password" id="oldPassword" name="oldPassword"
									class="form-control mb-3" required>
							</div>
							<div class="mb-3 w-100">
								<label for="newPassword" class="form-label me-3">새 비밀번호
									입력</label> <input type="password" id="newPassword" name="newPassword"
									class="form-control mb-3" required>
							</div>
							<div class="mb-3 w-100">
								<label for="newPassword_Check" class="form-label me-3">새
									비밀번호 다시 입력</label> <input type="password" id="newPassword_Check"
									name="newPassword_Check" class="form-control mb-3" required>
							</div>
							<button type="submit" class="btn btn-primary align-self-start">변경</button>
						</form>
					</td>
				</tr>
				<tr>
					<td>닉네임</td>
					<td>
						<form action="editNickName.jsp" method="post"
							class="d-flex align-items-center">
							<input type="text" id="nickname" name="nickname"
								placeholder="<%=nickname%>" class="form-control me-3" required>
							<button type="submit" class="btn btn-primary">변경</button>
						</form>
					</td>
				</tr>
				<tr>
					<td>이름</td>
					<td>
						<form action="editName.jsp" method="post"
							class="d-flex align-items-center">
							<input type="text" id="name" name="name" placeholder="<%=name%>"
								class="form-control me-3" required>
							<button type="submit" class="btn btn-primary">변경</button>
						</form>
					</td>
				</tr>
				<tr>
					<td>성별</td>
					<td><%=gender%></td>
				</tr>
				<tr>
					<td>핸드폰 번호</td>
					<td>
						<form action="editPhoneNum.jsp" method="post"
							class="d-flex align-items-center">
							<input type="text" id="phone_number" name="phone_number"
								placeholder="<%=phone_number%>" class="form-control me-3"
								required>
							<button type="submit" class="btn btn-primary">변경</button>
						</form>
					</td>
				</tr>
				<tr>
					<td>회원 등급</td>
					<td><%=level%></td>
				</tr>
				<tr>
					<td>이메일</td>
					<td>
						<form action="editEmail.jsp" method="post"
							class="d-flex align-items-center">
							<input type="text" id="email" name="email"
								placeholder="<%=email%>" class="form-control me-3" required>
							<button type="submit" class="btn btn-primary">변경</button>
						</form>
					</td>
				</tr>
				<tr>
					<td>권한 정보</td>
					<td><%=permission%></td>
				</tr>
			</tbody>
		</table>
		<div class="text-end mt-3 mb-5">
			<form id="withdrawalForm" action="Withdrawal.jsp" method="post" class="d-inline">
				<button type="submit" class="btn btn-danger">회원탈퇴</button>
			</form>
		</div>
	</div>
</body>
<script>
	function confirmWithdrawal(event) {
		if (!confirm("정말로 탈퇴하시겠습니까?")) {
			event.preventDefault();
		}
	}
	document.getElementById("withdrawalForm").addEventListener("submit", confirmWithdrawal);
</script>
</html>

