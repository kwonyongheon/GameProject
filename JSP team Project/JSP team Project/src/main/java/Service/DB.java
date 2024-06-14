package Service;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Date;
import java.util.regex.Pattern;
import javax.servlet.ServletContext;

import Board.MemberDTO;
import Board.PostDTO;
import Board.PostFileDTO;
import Board.ProblemDTO;
import answer.Comment;
import answer.Post;
import answer.Problem;
import answer.Reply;
import java.io.File;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class DB {

	static Connection con = null;
	static Statement stmt = null;
	static ResultSet rs = null;
	static PreparedStatement pstmt = null;

	static String driver = "com.mysql.cj.jdbc.Driver";
	static String URL = "jdbc:mysql://localhost:3306/sk_inside";

	// DB 로드 메소드
	public static void loadConnect() {

		disconnect();

		// 드라이버 로딩
		try {
			Class.forName(driver);

		} catch (java.lang.ClassNotFoundException e) {
			System.err.println("** Driver loaderror in loadConnect: " + e.getMessage());
			e.printStackTrace();

		}

		try {

			// 연결하기
			con = DriverManager.getConnection(URL, "root", "onlyroot");

			System.out.println("\n" + URL + "에 연결됨");

		} catch (SQLException ex) {

			System.err.println("** connection error in loadConnect(): " + ex.getMessage());
			ex.printStackTrace();
		}

	}

	// DB 로드 해제 메소드
	public static void disconnect() {
		try {
			// 연결을 닫는다.
			if (stmt != null)
				stmt.close();
			if (pstmt != null)
				pstmt.close();
			if (con != null)
				con.close();

			System.out.println("\n" + URL + "에 연결 해제됨");
		} catch (SQLException ex) {
		}
		;
	}

	// selectQuery메소드
	public static ResultSet selectQuery(String sql) {
		try {
			// Statement 생성
			// ResultSet에 커서 이동 메소드 사용하기 위해 craetStatemet () 메소드에
			// 매개변수로 ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY 추가
			stmt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

			rs = stmt.executeQuery(sql);

		} catch (SQLException ex) {
			System.err.println("** SQL exec error in selectQuery() : " + ex.getMessage());
		}

		return rs;
	}

	// 로그인 로직
	public static ResultSet LoginService(String id, String password) {
		try {
			String sql = "SELECT * FROM member WHERE ID = ? AND password = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, id);
			pstmt.setString(2, hashPassword(password)); // 입력 비밀번호를 해싱하여 비교
			rs = pstmt.executeQuery();
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in LoginService() : " + ex.getMessage());
		}
		return rs;
	}

	// 가입 메소드. id의 중복여부에 대해서 화인하는 로직--> 이미 id가 존재하면 result의 값이 -1, 가입이 되면 1, 오류발생시 0
	// 반환.
	public static int JoinService(String id, String password, String nickname, String name, String gender) {
		int result = 0;
		String insertSql = "INSERT INTO member (ID, password, nickname, name, permission, gender, level) VALUES (?, ?, ?, ?, ?, ?, ?)";
		try {
			rs = FindIdService(id);
			if (rs.next()) {
				result = -1; // ID가 존재하는 경우
			} else if (!isValidId(id)) {
				result = -2; // ID 유효성 검사 실패
			} else if (!isValidPassword(password)) {
				result = -3; // PW 유효성 검사 실패
			} else if (!isValidNickName(nickname)) {
				result = -4; // 닉네임 유효성 검사 실패
			} else if (!isValidName(name)) {
				result = -5; // 이름 유효성 검사 실패
			} else {
				String hashedPassword = hashPassword(password); // SHA-256 해쉬암호 알고리즘으로 암호화
				pstmt = con.prepareStatement(insertSql);
				pstmt.setString(1, id);
				pstmt.setString(2, hashedPassword); // 해싱된 비밀번호 저장
				pstmt.setString(3, nickname);
				pstmt.setString(4, name);
				pstmt.setString(5, "회원");
				pstmt.setString(6, gender);
				pstmt.setString(7, "D");
				result = pstmt.executeUpdate();
			}
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in JoinService() : " + ex.getMessage());
			result = 0; // 가입에 오류가 발생한 경우
		}
		return result;
	}

	// SHA-256 해싱 메서드
	public static String hashPassword(String password) {
		try {
			MessageDigest digest = MessageDigest.getInstance("SHA-256");
			byte[] hash = digest.digest(password.getBytes("UTF-8"));
			StringBuilder hexString = new StringBuilder();
			for (byte b : hash) {
				String hex = Integer.toHexString(0xff & b);
				if (hex.length() == 1)
					hexString.append('0');
				hexString.append(hex);
			}
			return hexString.toString();
		} catch (NoSuchAlgorithmException ex) {
			throw new RuntimeException("NoSuchAlgorithmException occurred while hashing the password", ex);
		} catch (java.io.UnsupportedEncodingException ex) {
			throw new RuntimeException("UnsupportedEncodingException occurred while hashing the password", ex);
		}
	}

	// 유효성 검사 메서드
	// 아이디 유효성
	private static boolean isValidId(String id) {
		// ID 유효성 검사 로직 (예: 알파벳과 숫자만 허용)
		return id != null && Pattern.matches("^[a-zA-Z0-9]+$", id);
	}

	// 비밀번호 유효성
	private static boolean isValidPassword(String password) {
		// 비밀번호 유효성 검사 로직 (예: 최소 8자 이상, 숫자, 특수문자 포함)
		return password != null && password.length() >= 8
				&& Pattern.matches("^(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$", password);
	}

	// 이름 유효성
	public static boolean isValidName(String name) {
		// 한글 2자에서 5자 사이의 이름만 허용하는 정규식
		String regex = "^[가-힣]{2,5}$";
		return name != null && name.matches(regex);
	}

	// 닉네임 유효성
	public static boolean isValidNickName(String nickname) {
		// 1~14글자 및 처음과 마지막글자에 공백 포함 불가능
		return nickname != null && !nickname.trim().isEmpty() && nickname.length() <= 14
				&& !Character.isWhitespace(nickname.charAt(0))
				&& !Character.isWhitespace(nickname.charAt(nickname.length() - 1));
	}

	// 전화번호 유효성
	public static boolean isValidPhoneNumber(String phoneNumber) {
		// 한국 전화번호 유효성 검사 정규식
		String regex = "^(\\d{2,3})[- ]?(\\d{3,4})[- ]?(\\d{4})$";
		return phoneNumber != null && phoneNumber.matches(regex);
	}

	// 이메일 유효성 검사
	public static boolean isValidEmail(String email) {
		// 이메일 주소 유효성 검사 정규식
		String regex = "^[a-zA-Z0-9+-\\_.]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$";
		return Pattern.matches(regex, email);
	}

	// id를 통해 회원정보를 찾는 메소드
	public static ResultSet FindIdService(String id) {
		try {
			String sql = "SELECT ID FROM member WHERE ID = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, id);
			rs = pstmt.executeQuery();
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in FindIdService() : " + ex.getMessage());
		}
		return rs;
	}

	// id를 통해 회원정보를 찾는 메소드
	public static ResultSet FindPhoneNumService(String phone_number) {
		try {
			String sql = "SELECT phone_number FROM member WHERE phone_number = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, phone_number);
			rs = pstmt.executeQuery();
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in FindPhoneNumService() : " + ex.getMessage());
		}
		return rs;
	}

	// membership_number를 통해 회원정보를 반환하는 메소드
	public static ResultSet FindByMembership_number(int membership_number) {
		try {
			String sql = "SELECT * FROM member WHERE membership_number = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, membership_number);
			rs = pstmt.executeQuery();
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in FindBymembership_number() : " + ex.getMessage());
		}

		return rs;
	}

	// 아이디 변경 메소드
	public static int updateIdService(String id, int membership_number) {
		int count;
		try {
			String sql = "UPDATE member SET ID = '" + id + "' WHERE membership_number = " + membership_number;
			rs = FindIdService(id);
			if (rs.next()) {
				count = -1; // 전에 사용하던 아이디
			} else if (!isValidId(id)) {
				count = -2; // ID유효성검사 실패
			} else {
				stmt = con.createStatement();
				count = stmt.executeUpdate(sql);
			}
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in updateID : " + ex.getMessage());
			count = 0;
		}
		return count;
	}

	// 패스워드 변경 메소드
	public static int updatePWService(String password, int membership_number) {
		int count = 0;
		try {
			rs = FindByMembership_number(membership_number);
			if (rs.next()) {
				String oldPW = rs.getString("password");
				if (oldPW.equals(hashPassword(password))) {
					count = -1; // 전에 사용하던 패스워드
				} else if (!isValidPassword(password)) {
					count = -2; // PW 유효성 검사 실패
				} else {
					String sql = "UPDATE member SET password = ? WHERE membership_number = ?";
					pstmt = con.prepareStatement(sql);
					pstmt.setString(1, hashPassword(password)); // 해싱된 비밀번호 저장
					pstmt.setInt(2, membership_number);
					count = pstmt.executeUpdate();
				}
			} else {
				count = 0; // 회원을 찾을 수 없음
			}
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in updatePW : " + ex.getMessage());
			count = 0;
		}
		return count;
	}

	// 닉네임 변경 메소드
	public static int updateNickNameService(String nickname, int membership_number) {
		int count = 0;
		try {
			// 닉네임이 null이 아니고, 공백이 아닌 문자열이며, 시작과 끝에 공백이 없는지 확인
			if (isValidNickName(nickname)) {
				String sql = "UPDATE member SET nickname = ? WHERE membership_number = ?";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, nickname);
				pstmt.setInt(2, membership_number);
				count = pstmt.executeUpdate();
			} else {
				count = -1; // 유효하지 않은 닉네임
			}
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in updateNickName : " + ex.getMessage());
			count = 0;
		}
		return count;
	}

	// 이름 변경 메소드
	public static int updateNameService(String name, int membership_number) {
		int count = 0;
		try {
			// 한국어2~5글자로 입력
			if (isValidName(name)) {
				String sql = "UPDATE member SET name = ? WHERE membership_number = ?";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, name);
				pstmt.setInt(2, membership_number);
				count = pstmt.executeUpdate();
			} else {
				count = -1; // 유효하지 않은 이름
			}
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in updateName : " + ex.getMessage());
			count = 0;
		}
		return count;
	}

	// 전화번호 변경 메소드
	public static int updatePhoneNumService(String phone_number, int membership_number) {
		int count = 0;
		try {
			String refinedPhoneNum = phone_number.replaceAll("[^0-9]", "");
			rs = FindPhoneNumService(refinedPhoneNum);
			if (rs.next()) {
				count = -2;
			} else if (isValidPhoneNumber(refinedPhoneNum)) {
				String sql = "UPDATE member SET phone_number = ? WHERE membership_number = ?";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, refinedPhoneNum);
				pstmt.setInt(2, membership_number);
				count = pstmt.executeUpdate();
			} else {
				count = -1; // 유효하지 않은 전화번호
			}
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in updatePhoneNum : " + ex.getMessage());
			count = 0;
		}
		return count;
	}

	// 이메일 변경 메소드
	public static int updateEmailService(String email, int membership_number) {
		int count = 0;
		try {
			if (isValidEmail(email)) {
				String sql = "UPDATE member SET email = ? WHERE membership_number = ?";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, email);
				pstmt.setInt(2, membership_number);
				count = pstmt.executeUpdate();
			} else {
				count = -1; // 유효하지 않은 전화번호
			}
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in updateEmail : " + ex.getMessage());
			count = 0;
		}
		return count;
	}

	// 문의하기 트랜잭션
	public static void inquiryTransaction(int membershipNumber, String title, String content, String fileName,
			String filePath) throws SQLException {
		// 명시적 트랜잭션으로 설정 --> 자동커밋모드 해제
		boolean autoCommit = con.getAutoCommit(); // 처음 자동커밋모드를 체크하고 값을 저장
		con.setAutoCommit(false);
		// 고객이 문의하기 기능 사용시 첨부파일이 있는경우 문의정보 DB를 먼저 생성하고 생성된 문의정보의 기본키로 문의 첨부파일 테이블에
		// 첨부파일정보를 저장 --> 트랜잭션 필요
		String insertInquirySQL = "INSERT INTO one_to_one_inquiry (inquiry_title, membership_number, inquiry_content, inquiry_time) VALUES (?, ?, ?, NOW())";
		try (PreparedStatement inquiryStmt = con.prepareStatement(insertInquirySQL, Statement.RETURN_GENERATED_KEYS)) {
			inquiryStmt.setString(1, title);
			inquiryStmt.setInt(2, membershipNumber);
			inquiryStmt.setString(3, content);
			inquiryStmt.executeUpdate();
			// 생성된 문의의 PK를 가져옴
			ResultSet rs = inquiryStmt.getGeneratedKeys();
			int inquiryNumber = 0;
			if (rs.next()) {
				inquiryNumber = rs.getInt(1);
			}
			// 생성된 문의PK로 파일정보 저장
			if (fileName != null && filePath != null) {
				String insertFileSQL = "INSERT INTO one_to_one_attached_file (inquiry_number, attached_file_name, upload_path) VALUES (?, ?, ?)";
				try (PreparedStatement fileStmt = con.prepareStatement(insertFileSQL)) {
					fileStmt.setInt(1, inquiryNumber);
					fileStmt.setString(2, fileName);
					fileStmt.setString(3, filePath);
					fileStmt.executeUpdate();
				}
			}
			// 커밋
			con.commit();
		} catch (SQLException e) {
			con.rollback(); // 예외 발생시 롤백
			throw e;
		} finally {
			con.setAutoCommit(autoCommit); // 자동커밋모드 원상복구
		}

	}

	// 문의 삭제 트랜잭션
	public static void DeleteInquiryTransaction(int inquiryNumber, int membershipNumber) throws SQLException {
		String deleteResponseSql = "DELETE FROM inquiry_response WHERE inquiry_number = ?";
		String deleteFileSql = "DELETE FROM one_to_one_attached_file WHERE inquiry_number = ?";
		String deleteInquirySql = "DELETE FROM one_to_one_inquiry WHERE inquiry_number = ? AND membership_number = ?";
		String filePath = null;
		boolean autoCommit = con.getAutoCommit(); // 처음 자동커밋모드를 체크하고 값을 저장
		con.setAutoCommit(false); // 명시적 트랜잭션 시작

		try {
			// 저장됨 첨부파일 삭제
			rs = FindInquiryFileInfo(inquiryNumber);
			if (rs.next()) {
				filePath = rs.getString("upload_path");
			}
			// 파일 삭제
			if (filePath != null) {
				File file = new File(filePath);
				if (file.exists()) {
					file.delete();
				}
			}
			// 문의 답장 내역 삭제
			pstmt = con.prepareStatement(deleteResponseSql);
			pstmt.setInt(1, inquiryNumber);
			pstmt.executeUpdate();
			pstmt.close();
			// 첨부파일 정보 삭제
			pstmt = con.prepareStatement(deleteFileSql);
			pstmt.setInt(1, inquiryNumber);
			pstmt.executeUpdate();
			pstmt.close();
			// 1대1문의 내역 삭제
			pstmt = con.prepareStatement(deleteInquirySql);
			pstmt.setInt(1, inquiryNumber);
			pstmt.setInt(2, membershipNumber);
			pstmt.executeUpdate();

			con.commit();
		} catch (SQLException e) {
			con.rollback();
			throw e;
		} finally {
			con.setAutoCommit(autoCommit);
		}

	}

	// membership_number를 통해 문의정보를 반환하는 메소드
	public static ResultSet FindInquiryInfo(int membership_number) {
		try {
			String sql = "SELECT o.inquiry_number, o.inquiry_title, o.inquiry_content, r.answer_content "
					+ "FROM one_to_one_inquiry o "
					+ "LEFT JOIN inquiry_response r ON o.inquiry_number = r.inquiry_number "
					+ "WHERE o.membership_number = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, membership_number);
			rs = pstmt.executeQuery();
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in FindInquiryInfo() : " + ex.getMessage());
		}

		return rs;
	}

	// inquiry_number를 통해 파일정보를 반환하는 메소드
	public static ResultSet FindInquiryFileInfo(int inquiry_number) {
		try {
			String sql = "select * from one_to_one_attached_file where inquiry_number = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, inquiry_number);
			rs = pstmt.executeQuery();
		} catch (SQLException ex) {
			System.err.println("** SQL exec error in FindInquiryFileInfo() : " + ex.getMessage());
		}

		return rs;
	}

	// 문의정보와 파일이름을 반환하는 메소드
	public static ResultSet FindInquiryJoinFileName() {
		String sql = "SELECT i.*, f.attached_file_name FROM one_to_one_inquiry i LEFT JOIN one_to_one_attached_file f ON i.inquiry_number = f.inquiry_number";
		rs = selectQuery(sql);
		return rs;
	}

	// 문의정보와 파일이름을 반환하는 메소드
	public static ResultSet FindInquiry(int inquiry_number) {
		try {
			String sql = "SELECT * FROM one_to_one_inquiry WHERE inquiry_number = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, inquiry_number);
			rs = pstmt.executeQuery();
		} catch (SQLException e) {
			System.err.println("** SQL exec error in FindInquiry() : " + e.getMessage());
		}
		return rs;
	}

	// 관리자가 문의 답장 전송
	public static int sendInquiryResponse(int inquiry_number, String answer_content) {
		int result = 0;
		try {
			String sql = "INSERT INTO inquiry_response (inquiry_number, answer_content) VALUES (?, ?)";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, inquiry_number);
			pstmt.setString(2, answer_content);
			result = pstmt.executeUpdate();
		} catch (SQLException e) {
			System.err.println("** SQL exec error in sendInquiryResponse() : " + e.getMessage());
		}
		return result;
	}

	// 게시물 작성 트랜잭션
	public static void PostTransaction(int membershipNumber, String title, String content, String fileName,
			String filePath) throws SQLException {
		// 명시적 트랜잭션으로 설정 --> 자동커밋모드 해제
		boolean autoCommit = con.getAutoCommit(); // 처음 자동커밋모드를 체크하고 값을 저장
		con.setAutoCommit(false);

		// 고객이 글쓰기 기능 사용시 첨부파일이 있는경우 게시물 DB를 먼저 생성하고 생성된 게시물의 기본키로 게시물 첨부파일 테이블에
		// 첨부파일정보를 저장 --> 트랜잭션 필요
		String insertPostSQL = "INSERT INTO post (member_number, post_title, post_content, number_of_recommendations, number_of_views) VALUES (?, ?, ?, 0, 0)";
		try (PreparedStatement postStmt = con.prepareStatement(insertPostSQL, Statement.RETURN_GENERATED_KEYS)) {
			postStmt.setInt(1, membershipNumber);
			postStmt.setString(2, title);
			postStmt.setString(3, content);
			postStmt.executeUpdate();
			// 생성된 게시물의 PK를 가져옴
			ResultSet rs = postStmt.getGeneratedKeys();
			int postNumber = 0;
			if (rs.next()) {
				postNumber = rs.getInt(1);
			}
			// 생성된 게시물PK로 파일정보 저장
			if (fileName != null && filePath != null) {
				String insertFileSQL = "INSERT INTO post_attachment_file (post_number, attached_file_name, upload_path) VALUES (?, ?, ?)";
				try (PreparedStatement fileStmt = con.prepareStatement(insertFileSQL)) {
					fileStmt.setInt(1, postNumber);
					fileStmt.setString(2, fileName);
					fileStmt.setString(3, filePath);
					fileStmt.executeUpdate();
				}
			}
			// 커밋
			con.commit();
		} catch (SQLException e) {
			con.rollback(); // 예외 발생시 롤백
			throw e;
		} finally {
			con.setAutoCommit(autoCommit); // 자동커밋모드 원상복구
		}
	}

	// 게시물 목록을 가져오는 메서드
	public static List<PostDTO> getPosts(int start, int count) {
		List<PostDTO> postList = new Vector<>();
		try {
			String query = "SELECT p.post_number, p.post_title, m.ID as member_id, p.number_of_recommendations, p.number_of_views "
					+ "FROM post p " + "JOIN member m ON p.member_number = m.membership_number "
					+ "ORDER BY p.post_number DESC " + "LIMIT ?, ?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, start);
			pstmt.setInt(2, count);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				PostDTO post = new PostDTO();
				post.setPost_number(rs.getInt("post_number"));
				post.setPost_title(rs.getString("post_title"));
				post.setMember_id(rs.getString("member_id")); // 작성자
				post.setNumber_of_recommendations(rs.getInt("number_of_recommendations"));
				post.setNumber_of_views(rs.getInt("number_of_views"));

				postList.add(post);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getPosts() : " + e.getMessage());
		}
		return postList;
	}

	// 게시물 수를 가져오는 메서드
	public static int getPostCount() {
		int count = 0;
		try {
			String query = "SELECT COUNT(*) FROM post";
			rs = selectQuery(query);
			if (rs.next()) {
				count = rs.getInt(1);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return count;
	}

	// 게시물의 조회수를 증가시키는 메서드
	public static void incrementViews(int postNumber) {
		try {
			String query = "UPDATE post SET number_of_views = number_of_views + 1 WHERE post_number=?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, postNumber);
			pstmt.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in incrementViews() : " + e.getMessage());
		}
	}

	// 문제 게시물의 조회수를 증가시키는 메서드
	public static void incrementProblemViews(int problemNumber) {
		try {
			String query = "UPDATE problem SET number_of_views = number_of_views + 1 WHERE problem_number=?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, problemNumber);
			pstmt.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in incrementProblemViews() : " + e.getMessage());
		}
	}

	// 특정 게시물을 가져오는 메서드
	public static PostDTO getPost(int postNumber) {
		PostDTO post = new PostDTO();
		try {
			String query = "SELECT p.*, m.ID as member_id FROM post p JOIN member m ON p.member_number = m.membership_number WHERE p.post_number = ?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, postNumber);
			rs = pstmt.executeQuery();

			if (rs.next()) {
				post.setPost_number(rs.getInt("post_number"));
				post.setPost_title(rs.getString("post_title"));
				post.setMember_number(rs.getInt("member_number"));
				post.setPost_content(rs.getString("post_content"));
				post.setNumber_of_recommendations(rs.getInt("number_of_recommendations"));
				post.setNumber_of_views(rs.getInt("number_of_views"));
				post.setMember_id(rs.getString("member_id")); // 작성자 아이디 설정
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getPost() : " + e.getMessage());
		}
		return post;
	}

	// 특정 문제를 가져오는 메서드
	public static ProblemDTO getProblem(int problemNumber) {
		ProblemDTO problem = new ProblemDTO();
		try {
			String query = "SELECT p.*, m.ID as member_id FROM problem p JOIN member m ON p.membership_number = m.membership_number WHERE p.problem_number = ?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, problemNumber);
			rs = pstmt.executeQuery();

			if (rs.next()) {
				problem.setProblem_number(rs.getInt("p.problem_number"));
				problem.setMembership_number(rs.getInt("p.membership_number"));
				problem.setProblem_title(rs.getString("p.problem_title"));
				problem.setCategory(rs.getString("p.category"));
				problem.setProblem_content(rs.getString("p.problem_content"));
				problem.setSolution_process(rs.getString("p.solution_process"));
				problem.setNumber_of_likes(rs.getInt("p.number_of_likes"));
				problem.setQuestion_date(rs.getString("p.question_date"));
				problem.setCorrect_answer(rs.getString("p.correct_answer"));
				problem.setNumber_of_views(rs.getInt("p.number_of_views"));
				problem.setMember_id(rs.getString("m.member_id")); // 작성자 아이디 설정
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getProblem() : " + e.getMessage());
		}
		return problem;
	}

	// 게시물을 추가하는 메서드
	public static int insertPost(int memberNumber, String postTitle, String postContent) {
		int postNumber = -1;
		try {
			String sql = "INSERT INTO post (member_number, post_title, post_content, number_of_recommendations, number_of_views) VALUES (?, ?, ?, 0, 0)";
			pstmt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
			pstmt.setInt(1, memberNumber);
			pstmt.setString(2, postTitle);
			pstmt.setString(3, postContent);
			int result = pstmt.executeUpdate();
			if (result > 0) {
				rs = pstmt.getGeneratedKeys();
				if (rs.next()) {
					postNumber = rs.getInt(1);
				}
				System.out.println("게시물이 성공적으로 추가되었습니다.");
			} else {
				System.out.println("게시물 추가에 실패했습니다.");
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in insertPost() : " + e.getMessage());
		}
		return postNumber;
	}

	// 게시물 번호로 첨부된 파일 목록 가져오기
	public static ResultSet getAttachedFiles(int postNumber) {
		try {
			String sql = "SELECT attached_file_name FROM post_attachment_file WHERE post_number = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, postNumber);
			rs = pstmt.executeQuery();
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getAttachedFiles() : " + e.getMessage());
		}
		return rs;
	}

	// 문제 번호로 첨부된 파일 목록 가져오기
	public static ResultSet getAttachedProblemFiles(int problemNumber) {
		try {
			String sql = "SELECT attached_file_name FROM problem_attachment_file WHERE problem_number = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, problemNumber);
			rs = pstmt.executeQuery();
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getAttachedProblemFiles() : " + e.getMessage());
		}
		return rs;
	}

	// 게시물 및 첨부 파일 정보 삭제
	public static boolean deletePost(int postNumber, ServletContext context) throws SQLException {
		String deletePostSql = "DELETE FROM post WHERE post_number = ?";
		String deleteFilesSql = "DELETE FROM post_attachment_file WHERE post_number = ?";
		String selectFilesSql = "SELECT attached_file_name FROM post_attachment_file WHERE post_number = ?";

		try (PreparedStatement deletePostStmt = con.prepareStatement(deletePostSql);
				PreparedStatement deleteFilesStmt = con.prepareStatement(deleteFilesSql);
				PreparedStatement selectFilesStmt = con.prepareStatement(selectFilesSql)) {
			con.setAutoCommit(false); // 트랜잭션 시작

			// 파일 이름 가져오기
			selectFilesStmt.setInt(1, postNumber);
			List<String> fileNames = new Vector<>();
			try (ResultSet rs = selectFilesStmt.executeQuery()) {
				while (rs.next()) {
					fileNames.add(rs.getString("attached_file_name"));
				}
			}

			// 파일 정보 삭제
			deleteFilesStmt.setInt(1, postNumber);
			deleteFilesStmt.executeUpdate();

			// 게시물 삭제
			deletePostStmt.setInt(1, postNumber);
			int affectedRows = deletePostStmt.executeUpdate();

			if (affectedRows > 0) {
				// 실제 파일 시스템에서 파일 삭제
				String uploadPath = context.getRealPath("/fileSave/");
				for (String fileName : fileNames) {
					File file = new File(uploadPath + File.separator + fileName);
					if (file.exists()) {
						file.delete();
					}
				}
			}
			con.commit(); // 트랜잭션 커밋
			return affectedRows > 0;
		} catch (SQLException e) {
			e.printStackTrace();
			con.rollback();
			throw e;
		}
	}

	// 게시물 수정 메서드
	public static void updatePost(int postNumber, String postTitle, String postContent) {
		try {
			String sql = "UPDATE post SET post_title = ?, post_content = ? WHERE post_number = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, postTitle);
			pstmt.setString(2, postContent);
			pstmt.setInt(3, postNumber);
			int affectedRows = pstmt.executeUpdate();
			if (affectedRows > 0) {
				System.out.println("게시물이 성공적으로 수정되었습니다.");
			} else {
				System.out.println("게시물 수정에 실패했습니다.");
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in updatePost() : " + e.getMessage());
		}
	}

	// 문제 수정 메서드
	public static void updateProblem(int problemNumber, String problemTitle, String problemContent,
			String correctAnswer, String solutionProcess) {
		try {
			String sql = "UPDATE problem SET problem_title = ?, problem_content = ?, correct_answer = ?, solution_process = ? WHERE problem_number = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, problemTitle);
			pstmt.setString(2, problemContent);
			pstmt.setString(3, correctAnswer);
			pstmt.setString(4, solutionProcess);
			pstmt.setInt(5, problemNumber);
			int affectedRows = pstmt.executeUpdate();
			if (affectedRows > 0) {
				System.out.println("게시물이 성공적으로 수정되었습니다.");
			} else {
				System.out.println("게시물 수정에 실패했습니다.");
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in updateProblem() : " + e.getMessage());
		}
	}

	// 특정 사용자가 특정 게시물을 추천했는지 여부를 확인하는 메서드
	public static boolean isPostRecommendedByUser(int postNumber, int memberNumber) {
		boolean isRecommended = false;
		try {
			String query = "SELECT COUNT(*) FROM post_recommendations WHERE post_number = ? AND member_number = ? AND check_member_recommendations = TRUE";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, postNumber);
			pstmt.setInt(2, memberNumber);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				isRecommended = rs.getInt(1) > 0;
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in isPostRecommendedByUser() : " + e.getMessage());
		}
		return isRecommended;
	}

	// 특정 사용자가 특정 문제를 추천했는지 여부를 확인하는 메서드
	public static boolean isProblemRecommendedByUser(int problemNumber, int memberNumber) {
		boolean isRecommended = false;
		try {
			String query = "SELECT COUNT(*) FROM problem_recommendations WHERE problem_number = ? AND member_number = ? AND check_member_recommendations = TRUE";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, problemNumber);
			pstmt.setInt(2, memberNumber);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				isRecommended = rs.getInt(1) > 0;
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in isProblemRecommendedByUser() : " + e.getMessage());
		}
		return isRecommended;
	}

	// 회원 번호로 게시물 목록을 가져오는 메서드
	public static List<PostDTO> getPostsByMemberNumber(int memberNumber, int start, int count) {
		List<PostDTO> postList = new Vector<>();
		try {
			String query = "SELECT p.*, m.ID as member_id FROM post p JOIN member m ON p.member_number = m.membership_number WHERE p.member_number = ? ORDER BY post_number DESC LIMIT ?, ?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, memberNumber);
			pstmt.setInt(2, start);
			pstmt.setInt(3, count);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				PostDTO post = new PostDTO();
				post.setPost_number(rs.getInt("post_number"));
				post.setPost_title(rs.getString("post_title"));
				post.setMember_number(rs.getInt("member_number"));
				post.setNumber_of_recommendations(rs.getInt("number_of_recommendations"));
				post.setNumber_of_views(rs.getInt("number_of_views"));
				post.setMember_id(rs.getString("member_id")); // 작성자
				postList.add(post);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getPostsByMemberNumber() : " + e.getMessage());
		}
		return postList;
	}

	// 회원 번호로 게시물 수를 가져오는 메서드
	public static int getPostCountByMemberNumber(int memberNumber) {
		int count = 0;
		try {
			String query = "SELECT COUNT(*) FROM post WHERE member_number = ?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, memberNumber);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				count = rs.getInt(1);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getPostCountByMemberNumber() : " + e.getMessage());
		}
		return count;
	}

	// 문제 상세 정보를 가져오는 메소드
	public static Problem getProblemDetails(int problemNumber) {
		try {
			String query = "SELECT problem_title, category, question_date, number_of_likes, number_of_views, problem_content FROM problem WHERE problem_number=?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, problemNumber);
			rs = pstmt.executeQuery();

			if (rs.next()) {
				Problem problem = new Problem(rs.getString("problem_title"), rs.getString("category"),
						rs.getTimestamp("question_date"), rs.getInt("number_of_likes"), rs.getInt("number_of_views"),
						rs.getString("problem_content"));
				return problem;
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getProblemDetails() : " + e.getMessage());
		}
		return null;
	}

	// 댓글 목록을 가져오는 메소드
	public static List<Comment> getComments(int problemNumber) {
		try {
			String query = "SELECT c.comment_content, c.writing_time, c.number_of_recommendations, m.ID, c.problem_comment_number, c.member_number "
					+ "FROM problem_comment AS c " + "JOIN member AS m ON c.member_number = m.membership_number "
					+ "WHERE c.problem_number = ? " + "ORDER BY c.number_of_recommendations DESC, c.writing_time DESC";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, problemNumber);
			rs = pstmt.executeQuery();

			List<Comment> comments = new Vector<>();
			while (rs.next()) {
				Comment comment = new Comment(rs.getInt("problem_comment_number"), rs.getInt("member_number"),
						rs.getString("ID"), rs.getString("comment_content"), rs.getTimestamp("writing_time"),
						rs.getInt("number_of_recommendations"));
				comments.add(comment);
			}
			return comments;
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getComments() : " + e.getMessage());
		}
		return null;
	}

	// 답글 목록을 가져오는 메소드
	public static List<Reply> getReplies(int commentNumber) {
		try {
			String query = "SELECT r.comment_content, r.writing_time, r.number_of_recommendations, m.ID, r.problem_reply_number, r.member_number "
					+ "FROM problem_reply AS r " + "JOIN member AS m ON r.member_number = m.membership_number "
					+ "WHERE r.problem_comment_number = ? "
					+ "ORDER BY r.number_of_recommendations DESC, r.writing_time ASC";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, commentNumber);
			rs = pstmt.executeQuery();

			List<Reply> replies = new ArrayList<>();
			while (rs.next()) {
				Reply reply = new Reply(rs.getInt("problem_reply_number"), rs.getInt("member_number"),
						rs.getString("ID"), rs.getString("comment_content"), rs.getTimestamp("writing_time"),
						rs.getInt("number_of_recommendations"));
				replies.add(reply);
			}
			return replies;
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getReplies() : " + e.getMessage());
		}
		return null;
	}

	// 댓글 추천 여부를 확인하는 메소드
	public static boolean isCommentLiked(int commentNumber, int memberNumber) {
		try {
			String query = "SELECT check_member_recommendations FROM problem_comment_recommendations WHERE problem_comment_number = ? AND member_number = ?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, commentNumber);
			pstmt.setInt(2, memberNumber);
			rs = pstmt.executeQuery();

			boolean liked = false;
			if (rs.next()) {
				liked = rs.getBoolean("check_member_recommendations");
			}
			return liked;
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in isCommentLiked() : " + e.getMessage());
		}
		return false;
	}

	// 답글 추천 여부를 확인하는 메소드
	public static boolean isReplyLiked(int replyNumber, int memberNumber) {
		try {
			String query = "SELECT check_member_recommendations FROM problem_reply_recommendations WHERE problem_reply_number = ? AND member_number = ?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, replyNumber);
			pstmt.setInt(2, memberNumber);
			rs = pstmt.executeQuery();

			boolean liked = false;
			if (rs.next()) {
				liked = rs.getBoolean("check_member_recommendations");
			}
			return liked;
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in isReplyLiked() : " + e.getMessage());
		}
		return false;
	}

	// 주어진 postNumber에 대한 게시물 상세 정보 가져오는 메소드
	public static Post getPostDetails(int postNumber) {
		try {
			String query = "SELECT post_title, post_content, number_of_recommendations, number_of_views FROM post WHERE post_number=?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, postNumber);
			rs = pstmt.executeQuery();

			if (rs.next()) {
				Post post = new Post(rs.getString("post_title"), rs.getString("post_content"),
						rs.getInt("number_of_recommendations"), rs.getInt("number_of_views"));
				return post;
			} else {
				return null;
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getPostDetailsd() : " + e.getMessage());
		}
		return null;
	}

	// 주어진 postNumber에 대한 모든 댓글을 가져오는 메소드
	public static List<Comment> getPostComments(int postNumber) {
		try {
			String query = "SELECT c.comment_content, c.writing_time, c.number_of_recommendations, m.ID, c.post_comment_number, c.member_number "
					+ "FROM post_comments AS c " + "JOIN member AS m ON c.member_number = m.membership_number "
					+ "WHERE c.post_number = ? " + "ORDER BY c.number_of_recommendations DESC, c.writing_time DESC";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, postNumber);
			rs = pstmt.executeQuery();

			List<Comment> comments = new Vector<>();
			while (rs.next()) {
				Comment comment = new Comment(rs.getInt("post_comment_number"), rs.getInt("member_number"),
						rs.getString("ID"), rs.getString("comment_content"), rs.getTimestamp("writing_time"),
						rs.getInt("number_of_recommendations"));
				comments.add(comment);
			}
			return comments;
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getPostComments() : " + e.getMessage());
		}
		return null;
	}

	// 주어진 problemNumber에 대한 모든 댓글을 가져오는 메소드
	public static List<Comment> getProblemComments(int problemNumber) {
		try {
			String query = "SELECT c.comment_content, c.writing_time, c.number_of_recommendations, m.ID, c.problem_comment_number, c.member_number "
					+ "FROM problem_comment AS c " + "JOIN member AS m ON c.member_number = m.membership_number "
					+ "WHERE c.problem_number = ? " + "ORDER BY c.number_of_recommendations DESC, c.writing_time DESC";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, problemNumber);
			rs = pstmt.executeQuery();

			List<Comment> comments = new Vector<>();
			while (rs.next()) {
				Comment comment = new Comment(rs.getInt("problem_comment_number"), rs.getInt("member_number"),
						rs.getString("ID"), rs.getString("comment_content"), rs.getTimestamp("writing_time"),
						rs.getInt("number_of_recommendations"));
				comments.add(comment);
			}
			return comments;
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getProblemComments() : " + e.getMessage());
		}
		return null;
	}

	// 주어진 commentNumber에 대한 모든 답글을 가져오는 메소드 --> 게시물
	public static List<Reply> getPostReplies(int commentNumber) {
		try {
			String query = "SELECT r.comment_content, r.writing_time, r.number_of_recommendations, m.ID, r.post_reply_number, r.member_number "
					+ "FROM post_reply AS r " + "JOIN member AS m ON r.member_number = m.membership_number "
					+ "WHERE r.post_comment_number = ? "
					+ "ORDER BY r.number_of_recommendations DESC, r.writing_time ASC";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, commentNumber);
			rs = pstmt.executeQuery();

			List<Reply> replies = new ArrayList<>();
			while (rs.next()) {
				Reply reply = new Reply(rs.getInt("post_reply_number"), rs.getInt("member_number"), rs.getString("ID"),
						rs.getString("comment_content"), rs.getTimestamp("writing_time"),
						rs.getInt("number_of_recommendations"));
				replies.add(reply);
			}
			return replies;
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getPostReplies() : " + e.getMessage());
		}
		return null;
	}

	// 주어진 commentNumber에 대한 모든 답글을 가져오는 메소드 --> 문제
	public static List<Reply> getProblemReplies(int commentNumber) {
		try {
			String query = "SELECT r.comment_content, r.writing_time, r.number_of_recommendations, m.ID, r.problem_reply_number, r.member_number "
					+ "FROM problem_reply AS r " + "JOIN member AS m ON r.member_number = m.membership_number "
					+ "WHERE r.problem_comment_number = ? "
					+ "ORDER BY r.number_of_recommendations DESC, r.writing_time ASC";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, commentNumber);
			rs = pstmt.executeQuery();

			List<Reply> replies = new ArrayList<>();
			while (rs.next()) {
				Reply reply = new Reply(rs.getInt("problem_reply_number"), rs.getInt("member_number"),
						rs.getString("ID"), rs.getString("comment_content"), rs.getTimestamp("writing_time"),
						rs.getInt("number_of_recommendations"));
				replies.add(reply);
			}
			return replies;
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getProblemReplies() : " + e.getMessage());
		}
		return null;
	}

	// 주어진 댓글에 대해 특정 사용자가 추천했는지 여부 확인하는 메소드
	public static boolean isPostCommentLiked(int commentNumber, int memberNumber) {
		try {
			String query = "SELECT check_member_recommendations FROM post_comment_recommendations WHERE post_comment_number = ? AND member_number = ?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, commentNumber);
			pstmt.setInt(2, memberNumber);
			rs = pstmt.executeQuery();

			boolean liked = false;
			if (rs.next()) {
				liked = rs.getBoolean("check_member_recommendations");
			}
			return liked;
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in isPostCommentLiked() : " + e.getMessage());
		}
		return false;
	}

	// 주어진 답글에 대해 특정 사용자가 추천했는지 여부 확인하는 메소드
	public static boolean isPostReplyLiked(int replyNumber, int memberNumber) {
		try {
			String query = "SELECT check_member_recommendations FROM post_reply_recommendations WHERE post_reply_number = ? AND member_number = ?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, replyNumber);
			pstmt.setInt(2, memberNumber);
			rs = pstmt.executeQuery();

			boolean liked = false;
			if (rs.next()) {
				liked = rs.getBoolean("check_member_recommendations");
			}
			return liked;
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in isPostReplyLiked() : " + e.getMessage());
		}
		return false;
	}

	// 파일 정보를 데이터베이스에 저장하는 메서드
	public static boolean insertFile(PostFileDTO file) {
		boolean success = false;
		try {
			String sql = "INSERT INTO post_attachment_file (post_number, attached_file_name, upload_path) VALUES (?, ?, ?)";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, file.getPost_number());
			pstmt.setString(2, file.getAttached_file_name());
			pstmt.setString(3, file.getUpload_path());
			int rowsInserted = pstmt.executeUpdate();
			if (rowsInserted > 0) {
				success = true;
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in insertFile() : " + e.getMessage());
		}
		return success;
	}

	// 등급 업데이트 메소드
	public static void updateMemberLevel(int memberNumber) {
		try {
			// 회원의 게시물 수를 가져옵니다.
			String postCountQuery = "SELECT COUNT(*) AS post_count FROM post WHERE member_number = ?";
			pstmt = con.prepareStatement(postCountQuery);
			pstmt.setInt(1, memberNumber);
			rs = pstmt.executeQuery();

			int postCount = 0;
			if (rs.next()) {
				postCount = rs.getInt("post_count");
			}

			// 회원의 문제 수를 가져옵니다.
			String problemCountQuery = "SELECT COUNT(*) AS problem_count FROM problem WHERE membership_number = ?";
			pstmt = con.prepareStatement(problemCountQuery);
			pstmt.setInt(1, memberNumber);
			rs = pstmt.executeQuery();

			int problemCount = 0;
			if (rs.next()) {
				problemCount = rs.getInt("problem_count");
			}

			// 총 게시물과 문제 수를 계산합니다.
			int totalContributions = postCount + problemCount;
			String newLevel = null;

			if (totalContributions >= 30) {
				newLevel = "A"; // 골드
			} else if (totalContributions >= 20) {
				newLevel = "B"; // 실버
			} else if (totalContributions >= 10) {
				newLevel = "C"; // 브론즈
			} else {
				newLevel = "D"; // 아이언
			}

			// 회원의 등급을 업데이트합니다.
			String updateLevelQuery = "UPDATE member SET level = ? WHERE membership_number = ?";
			pstmt = con.prepareStatement(updateLevelQuery);
			pstmt.setString(1, newLevel);
			pstmt.setInt(2, memberNumber);
			pstmt.executeUpdate();

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	// 회원 랭킹 가져오는 메모드
	public static List<MemberDTO> getMemberRanking() {
		List<MemberDTO> memberList = new ArrayList<>();
		try {
			String rankingQuery = "SELECT membership_number, ID, level FROM member ORDER BY FIELD(level, 'A', 'B', 'C', 'D')";
			pstmt = con.prepareStatement(rankingQuery);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				MemberDTO member = new MemberDTO();
				member.setMembershipNumber(rs.getInt("membership_number"));
				member.setId(rs.getString("ID"));
				member.setLevel(rs.getString("level"));
				memberList.add(member);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
		}
		return memberList;
	}

	// 문제 작성 트랜잭션
	public static void ProblemTransaction(int membershipNumber, String title, String content, String category,
			String correctAnswer, String solutionProcess, String fileName, String filePath) throws SQLException {
		// 명시적 트랜잭션으로 설정 --> 자동커밋모드 해제
		boolean autoCommit = con.getAutoCommit(); // 처음 자동커밋모드를 체크하고 값을 저장
		con.setAutoCommit(false);

		// 문제 정보를 DB에 삽입하고, 파일이 첨부된 경우 파일 정보를 저장하기 위한 트랜잭션
		String insertProblemSQL = "INSERT INTO problem (membership_number, problem_title, problem_content, category, correct_answer, solution_process, number_of_likes, question_date, number_of_views) VALUES (?, ?, ?, ?, ?, ?, 0, ?, 0)";
		try (PreparedStatement problemStmt = con.prepareStatement(insertProblemSQL, Statement.RETURN_GENERATED_KEYS)) {
			problemStmt.setInt(1, membershipNumber);
			problemStmt.setString(2, title);
			problemStmt.setString(3, content);
			problemStmt.setString(4, category);
			problemStmt.setString(5, correctAnswer);
			problemStmt.setString(6, solutionProcess);
			problemStmt.setString(7, new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
			problemStmt.executeUpdate();

			// 생성된 문제의 PK를 가져옴
			ResultSet rs = problemStmt.getGeneratedKeys();
			int problemNumber = 0;
			if (rs.next()) {
				problemNumber = rs.getInt(1);
			}

			// 생성된 문제PK로 파일정보 저장
			if (fileName != null && filePath != null) {
				String insertFileSQL = "INSERT INTO problem_attachment_file (problem_number, attached_file_name, upload_path) VALUES (?, ?, ?)";
				try (PreparedStatement fileStmt = con.prepareStatement(insertFileSQL)) {
					fileStmt.setInt(1, problemNumber);
					fileStmt.setString(2, fileName);
					fileStmt.setString(3, filePath);
					fileStmt.executeUpdate();
				}
			}

			// 회원 등급 업데이트
			updateMemberLevel(membershipNumber);

			// 커밋
			con.commit();
		} catch (SQLException e) {
			con.rollback(); // 예외 발생시 롤백
			throw e;
		} finally {
			con.setAutoCommit(autoCommit); // 자동커밋모드 원상복구
		}
	}

	// 새로운 글 가져오는 메서드
	public static List<ProblemDTO> getNewProblems(int limit) {
		List<ProblemDTO> problemList = new ArrayList<>();
		try {
			String query = "SELECT problem_number, problem_title FROM problem ORDER BY question_date DESC LIMIT ?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, limit);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				ProblemDTO problem = new ProblemDTO();
				problem.setProblem_number(rs.getInt("problem_number"));
				problem.setProblem_title(rs.getString("problem_title"));
				problemList.add(problem);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
		}
		return problemList;
	}

	// 인기 문제 가져오는 메서드
	public static List<ProblemDTO> getPopularProblems(int limit) {
		List<ProblemDTO> problemList = new ArrayList<>();
		try {
			String query = "SELECT problem_number, problem_title FROM problem ORDER BY number_of_likes DESC LIMIT ?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, limit);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				ProblemDTO problem = new ProblemDTO();
				problem.setProblem_number(rs.getInt("problem_number"));
				problem.setProblem_title(rs.getString("problem_title"));
				problemList.add(problem);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
		}
		return problemList;
	}

	// 문제 목록을 가져오는 메서드
	public static List<ProblemDTO> getProblems(int start, int count) {
		List<ProblemDTO> problemList = new ArrayList<>();
		try {
			String query = "SELECT * FROM problem ORDER BY problem_number DESC LIMIT ?, ?";
			pstmt = con.prepareStatement(query);
			pstmt.setInt(1, start);
			pstmt.setInt(2, count);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				ProblemDTO problem = new ProblemDTO();
				problem.setProblem_number(rs.getInt("problem_number"));
				problem.setProblem_title(rs.getString("problem_title"));
				problem.setProblem_content(rs.getString("problem_content"));
				problem.setCategory(rs.getString("category"));
				problem.setCorrect_answer(rs.getString("correct_answer"));
				problem.setSolution_process(rs.getString("solution_process"));
				problem.setNumber_of_likes(rs.getInt("number_of_likes"));
				problem.setQuestion_date(rs.getString("question_date"));
				problem.setNumber_of_views(rs.getInt("number_of_views"));
				problemList.add(problem);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getProblems() : " + e.getMessage());
		}
		return problemList;
	}

	// 문제 수를 가져오는 메서드
	public static int getProblemCount() {
		int count = 0;
		try {
			String query = "SELECT COUNT(*) FROM problem";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				count = rs.getInt(1);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("** SQL exec error in getProblemCount() : " + e.getMessage());
		}
		return count;
	}

	public static List<ProblemDTO> getProblemsByMemberNumber(int memberNumber, int start, int count) {
		List<ProblemDTO> problems = new ArrayList<>();
		String query = "SELECT * FROM problem WHERE membership_number = ? LIMIT ?, ?";
		try {
			PreparedStatement pstmt = con.prepareStatement(query);
			pstmt.setInt(1, memberNumber);
			pstmt.setInt(2, start);
			pstmt.setInt(3, count);
			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				ProblemDTO problem = new ProblemDTO();
				problem.setProblem_number(rs.getInt("problem_number"));
				problem.setMembership_number(rs.getInt("membership_number"));
				problem.setProblem_title(rs.getString("problem_title"));
				problem.setCategory(rs.getString("category"));
				problem.setCorrect_answer(rs.getString("correct_answer"));
				problem.setProblem_content(rs.getString("problem_content"));
				problem.setSolution_process(rs.getString("solution_process"));
				problem.setNumber_of_likes(rs.getInt("number_of_likes"));
				problem.setQuestion_date(rs.getString("question_date"));
				problem.setNumber_of_views(rs.getInt("number_of_views"));
				problems.add(problem);
			}
			rs.close();
			pstmt.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return problems;
	}

	// 사용자 번호에 따른 문제 개수 가져오기
	public static int getProblemCountByMemberNumber(int memberNumber) {
		int count = 0;
		String query = "SELECT COUNT(*) FROM problem WHERE membership_number = ?";
		try {
			PreparedStatement pstmt = con.prepareStatement(query);
			pstmt.setInt(1, memberNumber);
			ResultSet rs = pstmt.executeQuery();
			if (rs.next()) {
				count = rs.getInt(1);
			}
			rs.close();
			pstmt.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return count;
	}
	
	//회원탈퇴 메서드
	public static boolean withdrawal(int membership_number) throws SQLException {
		boolean commit = false;
		boolean autoCommit = con.getAutoCommit(); 
		String[] queries = {
	            "DELETE FROM report_problem_reply WHERE member_number = ?",
	            "DELETE r from report_problem_reply r join problem_reply p on r.problem_reply_number = p.problem_reply_number where p.member_number = ?",
	            "DELETE FROM report_problem_comment WHERE member_number = ?",
	            "DELETE r from report_problem_comment r join problem_comment p on r.problem_comment_number = p.problem_comment_number where p.member_number = ?",
	            "DELETE FROM report_post_reply WHERE member_number = ?",
	            "DELETE r from report_post_reply r join post_reply p on r.post_reply_number = p.post_reply_number where p.member_number = ?",
	            "DELETE FROM report_post_comment WHERE member_number = ?",	            
	            "DELETE r from report_post_comment r join post_comments p on r.post_comment_number = p.post_comment_number where p.member_number = ?",
	            "DELETE FROM problem_recommendations WHERE member_number = ?",
	            "DELETE r FROM problem_recommendations r join problem p on r.problem_number = p.problem_number WHERE p.membership_number = ?",
	            "DELETE FROM problem_reply_recommendations WHERE member_number = ?",
	            "DELETE r FROM problem_reply_recommendations r join problem_reply p on r.problem_reply_number = p.problem_reply_number WHERE p.member_number = ?",
	            "DELETE FROM problem_comment_recommendations WHERE member_number = ?",
	            "DELETE r FROM problem_comment_recommendations r join problem_comment p on r.problem_comment_number = p.problem_comment_number WHERE p.member_number = ?",
	            "DELETE FROM post_recommendations WHERE member_number = ?",
	            "DELETE r FROM post_recommendations r join post p on r.post_number = p.post_number WHERE p.member_number = ?",
	            "DELETE FROM post_reply_recommendations WHERE member_number = ?",	           	        
	            "DELETE r FROM post_reply_recommendations r join post_reply p on r.post_reply_number = p.post_reply_number WHERE p.member_number = ?",
	            "DELETE FROM post_comment_recommendations WHERE member_number = ?",
	            "DELETE r FROM post_comment_recommendations r join post_comments p on r.post_comment_number = p.post_comment_number WHERE p.member_number = ?",
	            "DELETE FROM problem_reply WHERE member_number = ?",	          
	            "DELETE FROM problem_comment WHERE member_number = ?",
	            "DELETE FROM post_reply WHERE member_number = ?",
	            "DELETE FROM post_comments WHERE member_number = ?",
	            "DELETE FROM problem_reply r where r.problem_comment_number IN(select problem_comment_number from problem_comment p join problem r on p.problem_number = r.problem_number where r.membership_number = ? AND p.problem_comment_number IN (SELECT problem_comment_number FROM problem_reply));",
	            "DELETE FROM post_reply r where r.post_comment_number IN(select post_comment_number from post_comments p join post r on p.post_number = r.post_number where r.member_number = ? AND p.post_comment_number IN (SELECT post_comment_number FROM post_reply));",
	            "DELETE r from problem_comment r join problem b on r.problem_number = b.problem_number where b.membership_number = ?",
	            "DELETE r from post_comments r join post b on r.post_number = b.post_number where b.member_number = ?",
	            "DELETE f FROM post_attachment_file f JOIN post p ON f.post_number = p.post_number WHERE p.member_number = ?",
	            "DELETE f FROM problem_attachment_file f JOIN problem p ON f.problem_number = p.problem_number WHERE p.membership_number = ?",
	            "DELETE FROM post WHERE member_number = ?",
	            "DELETE FROM problem WHERE membership_number = ?",
	            "DELETE r FROM inquiry_response r JOIN one_to_one_inquiry i ON r.inquiry_number = i.inquiry_number WHERE i.membership_number = ?",
	            "DELETE f FROM one_to_one_attached_file f JOIN one_to_one_inquiry i ON f.inquiry_number = i.inquiry_number WHERE i.membership_number = ?",
	            "DELETE FROM one_to_one_inquiry WHERE membership_number = ?",
	            "DELETE FROM member WHERE membership_number = ?"
	        };
		con.setAutoCommit(false);	
		try {
	        for (String query : queries) {
	            try (PreparedStatement pstmt = con.prepareStatement(query)) {
	                pstmt.setInt(1, membership_number);
	                pstmt.executeUpdate();
	            }
	        }
	        con.commit();
	        commit = true;
	        System.out.println("회원 정보가 성공적으로 삭제되었습니다.");
	    } catch (SQLException e) {
	        e.printStackTrace();
	        con.rollback(); // 오류 발생 시 롤백
	        System.out.println("오류가 발생하여 롤백되었습니다.");
	    } finally {
	        con.setAutoCommit(autoCommit); // 자동커밋모드 원상복구
	    }
	    return commit;
	}

	
	
	
	
}
