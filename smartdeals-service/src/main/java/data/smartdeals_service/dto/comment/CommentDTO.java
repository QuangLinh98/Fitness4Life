package data.smartdeals_service.dto.comment;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
@Data
public class CommentDTO { // lưu ý blogId và questionId ko được nhập vào cùng lúc
    private Long id;
    private Long userId; //nhập  id user
    private String userName; // nhập tên
    // nếu tạo comment trong blog thì đưa id vào
    private Long blogId; // liên kết id của blog
    // nếu tạo comment trong forum thì đưa id vào
    private Long questionId; // liên kết id của question
    private Long parentCommentId; // liên kết id của comment cha nếu có (dùng cho reply)
    private String content;
    private Boolean isPublished;
    private LocalDateTime createdAt;
    private List<CommentDTO> replies = new ArrayList<>();

}
