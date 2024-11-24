package data.smartdeals_service.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import data.smartdeals_service.dto.CommentDTO;
import data.smartdeals_service.models.Blog;
import data.smartdeals_service.models.Question;
import lombok.AllArgsConstructor;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@AllArgsConstructor
public class CommentConsumer {
    private final ObjectMapper objectMapper;
    private final BlogService blogService;
    private final ForumService forumService;
    private final CommentService commentService;

    @KafkaListener(topics = "comment-topic", groupId = "comment-group", concurrency = "3")
    private void listen(String message) {
        try {
            CommentDTO comments = objectMapper.readValue(message, CommentDTO.class);

            Optional<Blog> existingBlog = blogService.findById(comments.getBlogId());
            if (existingBlog.isPresent()) {
                commentService.createCommentBlog(comments);
                return; // Nếu Blog có dữ liệu, bỏ qua việc xử lý Question
            }

            Optional<Question> existingQuestion = forumService.findById(comments.getQuestionId());
            if (existingQuestion.isPresent()) {
                commentService.createCommentForum(comments);
                return; // Nếu Question có dữ liệu, bỏ qua các bước tiếp theo
            }

            // Nếu cả Blog và Question đều không có dữ liệu, thông báo lỗi
            System.out.println("gui mail bao loi cho nguoi dung");
            throw new RuntimeException("BLOGANDQUESTIONNOTFOUND");

        } catch (Exception e) {
            System.out.println("failed to process feed message: " + e.getMessage());
        }
    }

}
