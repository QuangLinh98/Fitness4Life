package data.smartdeals_service.dto;

import lombok.Data;

@Data
public class CreateReplyDTO {
    private Long blogId; // ID của bài blog mà bình luận này sẽ thuộc về
    private Long parentCommentId; // ID của bình luận cha
    private String content; // Nội dung bình luận
    private Long authorId; // ID của tác giả bình luận
    private String authorName; // Tên tác giả bình luận
}
