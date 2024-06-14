package Board;

public class ProblemDTO {
    private int problem_number;
    private int membership_number;
    private String problem_title;
    private String category;
    private String correct_answer;
    private String problem_content;
    private String solution_process;
    private int number_of_likes;
    private String question_date;
    private int number_of_views;
	private String member_id;

    // Getters and Setters
    public int getProblem_number() {
        return problem_number;
    }

    public void setProblem_number(int problem_number) {
        this.problem_number = problem_number;
    }

    public int getMembership_number() {
        return membership_number;
    }

    public void setMembership_number(int membership_number) {
        this.membership_number = membership_number;
    }

    public String getProblem_title() {
        return problem_title;
    }

    public void setProblem_title(String problem_title) {
        this.problem_title = problem_title;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getCorrect_answer() {
        return correct_answer;
    }

    public void setCorrect_answer(String correct_answer) {
        this.correct_answer = correct_answer;
    }

    public String getProblem_content() {
        return problem_content;
    }

    public void setProblem_content(String problem_content) {
        this.problem_content = problem_content;
    }

    public String getSolution_process() {
        return solution_process;
    }

    public void setSolution_process(String solution_process) {
        this.solution_process = solution_process;
    }

    public int getNumber_of_likes() {
        return number_of_likes;
    }

    public void setNumber_of_likes(int number_of_likes) {
        this.number_of_likes = number_of_likes;
    }

    public String getQuestion_date() {
        return question_date;
    }

    public void setQuestion_date(String question_date) {
        this.question_date = question_date;
    }

    public int getNumber_of_views() {
        return number_of_views;
    }

    public void setNumber_of_views(int number_of_views) {
        this.number_of_views = number_of_views;
    }
    
    public String getMember_id() {
        return member_id;
    }

    public void setMember_id(String member_id) {
        this.member_id = member_id;
    }
}