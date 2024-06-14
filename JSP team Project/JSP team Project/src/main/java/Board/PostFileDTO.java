package Board;

public class PostFileDTO {
    private int attached_file_number;
    private int post_number;
    private String attached_file_name;
    private String upload_path;
    
    // 생성자, getter 및 setter 메서드 추가
	public int getAttached_file_number() {
		return attached_file_number;
	}
	public void setAttached_file_number(int attached_file_number) {
		this.attached_file_number = attached_file_number;
	}
	public int getPost_number() {
		return post_number;
	}
	public void setPost_number(int post_number) {
		this.post_number = post_number;
	}
	public String getAttached_file_name() {
		return attached_file_name;
	}
	public void setAttached_file_name(String attached_file_name) {
		this.attached_file_name = attached_file_name;
	}
	public String getUpload_path() {
		return upload_path;
	}
	public void setUpload_path(String upload_path) {
		this.upload_path = upload_path;
	}

}
