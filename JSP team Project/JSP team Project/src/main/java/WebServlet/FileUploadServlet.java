package WebServlet;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.util.UUID;
import Service.DB;

@WebServlet("/upload")
@MultipartConfig
public class FileUploadServlet extends HttpServlet {
	// 업로드 파일 저장 절대경로 작성
	private static final String UPLOAD_DIR = "C:\\Users\\ksk69\\desktop\\바탕 화면\\DP programing\\JSP team Project\\src\\main\\webapp\\fileSave\\";

	// 업로드 된 파일에서 이름 추출 메서드
	private String getFileName(final Part part) {
		for (String content : part.getHeader("content-disposition").split(";")) {
			if (content.trim().startsWith("filename")) {
				return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
			}
		}
		return null;
	}

	// 파일 업로드 후
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// 인코딩 타입 설정
		request.setCharacterEncoding("UTF-8");
		response.setContentType("text/html; charset=UTF-8");
		// 전달받은 파라메터 설정
		String title = request.getParameter("title");
		String content = request.getParameter("content");
		Part filePart = request.getPart("file");
		String fileName = null;
		String filePath = null;
		// 로그인된 회원번호 가져오기
		HttpSession session = request.getSession();
		Integer membershipNumber = (Integer) session.getAttribute("membership_number");
		if (membershipNumber == null) {
			response.sendRedirect("Login.jsp");
			return;
		}

		// 업로드된 파일로부터 파일 이름과 경로 설정
		if (filePart != null && filePart.getSize() > 0) {
			fileName = UUID.randomUUID().toString() + "_" + getFileName(filePart);
			filePath = UPLOAD_DIR + fileName;
			// UPLOAD_DIR가 없으면 생성
			File uploadDir = new File(UPLOAD_DIR);
			if (!uploadDir.exists()) {
				uploadDir.mkdir();
			}
			// 업로드된 파일을 읽어서 filePath로 저장
			try (OutputStream fileOutputStream = new FileOutputStream(new File(filePath));
					InputStream fileContent = filePart.getInputStream()) {
				int read;
				final byte[] bytes = new byte[1024];
				while ((read = fileContent.read(bytes)) != -1) {
					fileOutputStream.write(bytes, 0, read);
				}
			} catch (Exception e) {
				e.printStackTrace();
				response.getWriter().println("<script>alert('파일 업로드 실패: 파일 저장 오류'); history.back();</script>");
				return;
			}
		}

		//저장된 파일 및 문의내용 DB저장 트랜잭션 실행
		DB.loadConnect();
		try {
			DB.inquiryTransaction(membershipNumber, title, content, fileName, filePath);
			response.getWriter()
					.println("<script>alert('문의글과 파일이 성공적으로 전송되었습니다.'); location.replace('content.jsp');</script>");
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			response.getWriter()
			.println("<script>alert('문의글 전송 실패. 관리자에게 문의하세요.'); location.replace('content.jsp');</script>");
		}
		DB.disconnect();

	}
	

}
