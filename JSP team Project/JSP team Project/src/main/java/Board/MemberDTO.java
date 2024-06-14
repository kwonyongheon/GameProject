package Board;

public class MemberDTO {
    private int membershipNumber;
    private String id;
    private String level;

    public int getMembershipNumber() {
        return membershipNumber;
    }

    public void setMembershipNumber(int membershipNumber) {
        this.membershipNumber = membershipNumber;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getLevelString() {
        switch (this.level) {
            case "A":
                return "골드";
            case "B":
                return "실버";
            case "C":
                return "브론즈";
            case "D":
                return "아이언";
            default:
                return "언랭";
        }
    }
}