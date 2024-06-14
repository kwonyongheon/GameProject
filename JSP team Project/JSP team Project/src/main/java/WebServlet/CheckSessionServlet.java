package WebServlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/CheckSessionServlet")
public class CheckSessionServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer membership_number = (Integer) session.getAttribute("membership_number");

        if (membership_number != null) {
            response.getWriter().write("true");
        } else {
            response.getWriter().write("false");
        }
    }
}
