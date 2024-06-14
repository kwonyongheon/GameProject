package WebServlet;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import Board.ProblemDTO;
import Service.DB;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/CheckAnswerServlet")
public class CheckAnswerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 요청의 인코딩 설정
        request.setCharacterEncoding("UTF-8");

        // 응답의 인코딩과 콘텐츠 타입 설정
        response.setContentType("text/plain; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        // 클라이언트로부터 전달받은 문제 번호와 답
        int problemNumber = Integer.parseInt(request.getParameter("problemNumber"));
        String userAnswer = request.getParameter("answer");

        
            // 데이터베이스 연결
            DB.loadConnect();

            // 문제의 정답을 조회하는 SQL 쿼리
            ProblemDTO pro = DB.getProblem(problemNumber);
            	
                // 데이터베이스에서 조회한 정답
                String correctAnswer = pro.getCorrect_answer();

                // 사용자 답과 데이터베이스 정답을 비교
                if (userAnswer.equals(correctAnswer)) {
                    out.print("correct");
                } else {
                    out.print("incorrect");
                }                
        DB.disconnect();
    }
}
