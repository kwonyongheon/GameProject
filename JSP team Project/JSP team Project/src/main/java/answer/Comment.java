package answer;

import java.sql.Timestamp;

public class Comment {
    private int commentNumber;
    private int memberNumber;
    private String memberId;
    private String content;
    private Timestamp writingTime;
    private int recommendations;

    public Comment(int commentNumber, int memberNumber, String memberId, String content, Timestamp writingTime, int recommendations) {
        this.commentNumber = commentNumber;
        this.memberNumber = memberNumber;
        this.memberId = memberId;
        this.content = content;
        this.writingTime = writingTime;
        this.recommendations = recommendations;
    }

    public int getCommentNumber() {
        return commentNumber;
    }

    public int getMemberNumber() {
        return memberNumber;
    }

    public String getMemberId() {
        return memberId;
    }

    public String getContent() {
        return content;
    }

    public Timestamp getWritingTime() {
        return writingTime;
    }

    public int getRecommendations() {
        return recommendations;
    }
}
