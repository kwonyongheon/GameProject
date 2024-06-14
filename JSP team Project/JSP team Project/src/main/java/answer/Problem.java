package answer;

import java.sql.Timestamp;

public class Problem {
    private String title;
    private String category;
    private Timestamp date;
    private int likes;
    private int views;
    private String content;

    public Problem(String title, String category, Timestamp date, int likes, int views, String content) {
        this.title = title;
        this.category = category;
        this.date = date;
        this.likes = likes;
        this.views = views;
        this.content = content;
    }

    public String getTitle() {
        return title;
    }

    public String getCategory() {
        return category;
    }

    public Timestamp getDate() {
        return date;
    }

    public int getLikes() {
        return likes;
    }

    public int getViews() {
        return views;
    }

    public String getContent() {
        return content;
    }
}
