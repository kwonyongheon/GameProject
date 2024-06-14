package answer;

public class Post {
    private String title;
    private String content;
    private int recommendations;
    private int views;

    public Post(String title, String content, int recommendations, int views) {
        this.title = title;
        this.content = content;
        this.recommendations = recommendations;
        this.views = views;
    }

    public String getTitle() {
        return title;
    }

    public String getContent() {
        return content;
    }

    public int getRecommendations() {
        return recommendations;
    }

    public int getViews() {
        return views;
    }
}
