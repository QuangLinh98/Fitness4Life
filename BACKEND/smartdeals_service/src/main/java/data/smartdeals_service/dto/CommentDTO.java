package data.smartdeals_service.dto;

import lombok.Data;
import java.util.ArrayList;
import java.util.List;
@Data
public class CommentDTO {

    private Long userId; //nhập  id user
    private String userName; // nhập tên
    private Long blogId; // liên kết id của blog
    private Long questionId; // liên kết id của question
    private Long parentCommentId; // liên kết id của comment cha nếu có (dùng cho reply)
    private String content;
    private Boolean isPublished; // trạng thái của bình luận
    private List<CommentDTO> replies = new ArrayList<>();

}
