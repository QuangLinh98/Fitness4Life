package data.smartdeals_service.dto;


import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Data
public class CreateCommentForumDTO {
    private String content;
    private String author;
    private Long parentId; // Bình luận cha
    private Long questionId; // Câu hỏi liên quan

    private List<CreateCommentForumDTO> replies = new ArrayList<>(); // Danh sách trả lời
}
