package data.smartdeals_service.services.kafkaServices;

import com.fasterxml.jackson.databind.ObjectMapper;
import data.smartdeals_service.dto.NotifyDTO;
import data.smartdeals_service.dto.comment.CommentDTO;
import data.smartdeals_service.dto.user.UserDTO;
import data.smartdeals_service.eureka_client.ErurekaService;
import data.smartdeals_service.models.blog.Blog;
import data.smartdeals_service.models.comment.Comment;
import data.smartdeals_service.models.forum.Question;
import data.smartdeals_service.notification.NotifyService;
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
    private final ErurekaService userEurekaClient;
    private final NotifyService notifyService;

    @KafkaListener(topics = "comment-topic", groupId = "comment-group", concurrency = "3")
    private void listen(String message) {
        try {
            CommentDTO comments = objectMapper.readValue(message, CommentDTO.class);
            Optional<Blog> existingBlog = Optional.empty();
            if (comments.getBlogId() != null) {
                existingBlog = blogService.findById(comments.getBlogId());
            }
            if (existingBlog.isPresent()) {
                commentService.createCommentBlog(comments);
                return;
            }
            UserDTO existingUser = userEurekaClient.getUserById(comments.getUserId());
            Optional<Question> existingQuestion = Optional.empty();
            if (comments.getQuestionId() != null) {
                existingQuestion = questionService.findById(comments.getQuestionId());
            }
            if (existingQuestion.isPresent()) {
               Comment save = commentService.createCommentForum(comments);

                NotifyDTO notifyDTO = new NotifyDTO();
                notifyDTO.setItemId(comments.getQuestionId());
                notifyDTO.setUserId(existingQuestion.get().getAuthorId());
                notifyDTO.setFullName(existingQuestion.get().getAuthor());
                notifyDTO.setToken(comments.getToken());
                notifyService.sendCreatedNotification(existingUser, notifyDTO, save);

                if(save.getParentComment() != null) {
                    notifyService.sendReplyOfComentNotification(existingUser, notifyDTO, save);
                }
                return;
            }
            throw new RuntimeException("BLOGANDQUESTIONNOTFOUND");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
