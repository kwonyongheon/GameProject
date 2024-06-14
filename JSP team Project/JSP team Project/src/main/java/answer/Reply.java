package answer;

import java.sql.Timestamp;

public class Reply {
    private int replyNumber;
    private int memberNumber;
    private String memberId;
    private String content;
    private Timestamp writingTime;
    private int recommendations;

    public Reply(int replyNumber, int memberNumber, String memberId, String content, Timestamp writingTime, int recommendations) {
        this.replyNumber = replyNumber;
        this.memberNumber = memberNumber;
        this.memberId = memberId;
        this.content = content;
        this.writingTime = writingTime;
        this.recommendations = recommendations;
    }

    public int getReplyNumber() {
        return replyNumber;
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
