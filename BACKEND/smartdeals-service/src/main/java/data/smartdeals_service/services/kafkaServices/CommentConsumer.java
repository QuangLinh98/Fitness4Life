package data.smartdeals_service.services.kafkaServices;

import com.fasterxml.jackson.databind.ObjectMapper;
import data.smartdeals_service.dto.comment.CommentDTO;
import data.smartdeals_service.models.blog.Blog;
import data.smartdeals_service.models.forum.Question;
import data.smartdeals_service.services.blogServices.BlogService;
import data.smartdeals_service.services.commentServices.CommentService;
import data.smartdeals_service.services.forumServices.QuestionService;
import lombok.AllArgsConstructor;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@AllArgsConstructor
public class CommentConsumer {
    private final ObjectMapper objectMapper;
    private final BlogService blogService;
    private final QuestionService questionService;
    private final CommentService commentService;

    @KafkaListener(topics = "comment-topic", groupId = "comment-group", concurrency = "3")
    private void listen(String message) {
        try {
            CommentDTO comments = objectMapper.readValue(message, CommentDTO.class);

            // Log dữ liệu nhận được
            System.out.println("Received message: " + comments);

            Optional<Blog> existingBlog = Optional.empty();
            if (comments.getBlogId() != null) {
                existingBlog = blogService.findById(comments.getBlogId());
            }
            if (existingBlog.isPresent()) {
                commentService.createCommentBlog(comments);
                return; // Nếu Blog có dữ liệu, bỏ qua việc xử lý Question
            }

            Optional<Question> existingQuestion = Optional.empty();
            if (comments.getQuestionId() != null) {
                existingQuestion = questionService.findById(comments.getQuestionId());
            }
            if (existingQuestion.isPresent()) {
                commentService.createCommentForum(comments);
                return; // Nếu Question có dữ liệu, bỏ qua các bước tiếp theo
            }

            // Nếu cả Blog và Question đều không có dữ liệu, thông báo lỗi
            System.out.println("No Blog or Question found for this comment.");
            throw new RuntimeException("BLOGANDQUESTIONNOTFOUND");

        } catch (Exception e) {
            System.out.println("failed to process feed message: " + e.getMessage());
            e.printStackTrace();
        }
    }

}
