package WebServlet;

import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.util.UUID;
import Service.DB;

@WebServlet("/postUpload")
@MultipartConfig
public class PostFileUploadServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "C:\\Users\\ksk69\\desktop\\바탕 화면\\DP programing\\JSP team Project\\src\\main\\webapp\\fileSave\\";

    private String getFileName(final Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String title = request.getParameter("title");
        String content = request.getParameter("content");
        Part filePart = request.getPart("file");

        HttpSession session = request.getSession();
        Integer membershipNumber = (Integer) session.getAttribute("membership_number");

        if (membershipNumber == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String fileName = null;
        String filePath = null;

        if (filePart != null && filePart.getSize() > 0) {
            fileName = UUID.randomUUID().toString() + "_" + getFileName(filePart);
            filePath = UPLOAD_DIR + fileName;

            File uploadDir = new File(UPLOAD_DIR);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }

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

        DB.loadConnect();
        try {
            DB.PostTransaction(membershipNumber, title, content, fileName, filePath);
            response.getWriter().println("<script>alert('글이 성공적으로 작성되었습니다.'); location.replace('PostList.jsp');</script>");
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println("<script>alert('글 전송 실패. 관리자에게 문의하세요.'); location.replace('content.jsp');</script>");
        } finally {
            DB.disconnect();
        }
    }
    // 사진의 크기를 비율을 유지한 채로 기본값에 가깝게 크기 조정
    private BufferedImage resizeImage(BufferedImage originalImage, int maxWidth, int maxHeight) {
        int originalWidth = originalImage.getWidth();
        int originalHeight = originalImage.getHeight();
        int targetWidth = originalWidth;
        int targetHeight = originalHeight;

        if (originalWidth > maxWidth) {
            targetWidth = maxWidth;
            targetHeight = (int) (originalHeight * ((double) maxWidth / originalWidth));
        }

        if (targetHeight > maxHeight) {
            targetHeight = maxHeight;
            targetWidth = (int) (originalWidth * ((double) maxHeight / originalHeight));
        }

        Image resultingImage = originalImage.getScaledInstance(targetWidth, targetHeight, Image.SCALE_SMOOTH);
        BufferedImage outputImage = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d = outputImage.createGraphics();
        g2d.drawImage(resultingImage, 0, 0, null);
        g2d.dispose();
        return outputImage;
    }

    
}
