<%@ page language="java"
    contentType="application/octet-stream; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.sql.*, javax.servlet.http.*, java.io.*, Service.*"%>
<%
    request.setCharacterEncoding("UTF-8");
    DB.loadConnect();
    
    int inquiryNumber = Integer.parseInt(request.getParameter("inquiryNumber"));
    ResultSet rs = DB.FindInquiryFileInfo(inquiryNumber);
    
    if (rs.next()) {
        // 첨부파일명과 경로 가져오기
        String fileName = rs.getString("attached_file_name");
        String filePath = rs.getString("upload_path");
    
        // 첨부파일을 읽어들이기 위한 InputStream 생성
        InputStream inputStream = null;
        try {
            inputStream = new FileInputStream(filePath);
        
            // 파일 다운로드를 위한 설정
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        
            // 읽어들인 파일을 클라이언트에 출력
            OutputStream outputStream = response.getOutputStream();
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
            outputStream.close();
        } catch (FileNotFoundException e) {
            response.setContentType("text/html");
            out.println("<script>alert('파일을 찾을 수 없습니다. 해당파일이 삭제된 것 같습니다.'); history.back();</script>");
        } finally {
            if (inputStream != null) {
                inputStream.close();
            }
        }
    } else {
        out.println("<h2>DB 조회 결과 없음.</h2>");
    }
    
    DB.disconnect();
%>
