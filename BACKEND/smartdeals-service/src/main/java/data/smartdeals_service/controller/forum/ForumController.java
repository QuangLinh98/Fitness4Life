package data.smartdeals_service.controller.forum;

import data.smartdeals_service.dto.comment.ChangeStatusCommentDTO;
import data.smartdeals_service.dto.comment.CommentDTO;
import data.smartdeals_service.dto.forum.QuestionDTO;
import data.smartdeals_service.helpers.ApiResponse;
import data.smartdeals_service.models.comment.Comment;
import data.smartdeals_service.models.forum.Question;
import data.smartdeals_service.services.kafkaServices.CommentProducer;
import data.smartdeals_service.services.commentServices.CommentService;
import data.smartdeals_service.services.forumServices.QuestionService;
import data.smartdeals_service.services.spam.SpamFilterService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/api/forums")
@RequiredArgsConstructor
public class ForumController {
    private final QuestionService questionService;
    private final CommentService commentService;
    private final CommentProducer commentProducer;
    private final SpamFilterService spamFilterService;
    @GetMapping("/questions")
    public ResponseEntity<?> getAllQuestion() {
        try {
            List<Question> questions = questionService.findAll();
            return ResponseEntity.ok(ApiResponse.success(questions, "get all questions successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @GetMapping("/questions/{id}")
    public ResponseEntity<?> getQuestionById(@PathVariable Long id) {
        try {
            Optional<Question> questions = questionService.findById(id);
            if (questions != null) {
                return ResponseEntity.status(200).body(ApiResponse
                        .success(questions, "get one questions successfully"));
            } else {
                return ResponseEntity.status(404).body(ApiResponse
                        .notfound("questions not found"));
            }
        } catch (Exception ex) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
        }
    }

    @PostMapping("/questions/create")
    public ResponseEntity<?> createQuestion(@RequestBody QuestionDTO questionDTO,
                                        BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Question savedQuestion = questionService.createQuestion(questionDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(savedQuestion,"create Question successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    @PutMapping("/questions/update")
    public ResponseEntity<?> updateQuestion(@PathVariable Long id,@RequestBody QuestionDTO questionDTO,
                                            BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Question updateQuestion = questionService.updateQuestion(id,questionDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(updateQuestion,"update Question  successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @DeleteMapping("/deleteQuestion/{id}")
    public void deleteQuestion(@PathVariable Long id) {
        questionService.deleteQuestion(id);
    }

    // Tạo bình luận hoặc trả lời bình luận
    @PostMapping("/comment/create")
    public ResponseEntity<?> createComment( @Valid @RequestBody CommentDTO comment,
                                           BindingResult bindingResult) {
        try {
            // Phát hiện ngôn ngữ (tự động hoặc dựa vào tham số đầu vào)
            String detectedLanguage = spamFilterService.detectLanguage(comment.getContent());
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            if (spamFilterService.isSpam(comment.getContent(),detectedLanguage)) {
                return ResponseEntity.badRequest().body("Your comment contains spam words and cannot be accepted.");
            }
//            commentService.createCommentForum(comment);
            commentProducer.sendComment(comment);
            return  ResponseEntity.ok("create Comment successfully");
        } catch (Exception ex) {
            if(ex.getMessage().contains("BLOGANDQUESTIONNOTFOUND")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("question not found"));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    // Lấy danh sách bình luận theo câu hỏi
    @GetMapping("/commentFlowerQuestions/{questionId}")
    public ResponseEntity<?> getCommentsByQuestion(@PathVariable Long questionId) {
        try {
            List<Comment> commentInQuestions = commentService.getCommentsByQuestion(questionId);
            if (commentInQuestions != null) {
                return ResponseEntity.status(200).body(ApiResponse
                        .success(commentInQuestions, "get one comment In Questions successfully"));
            } else {
                return ResponseEntity.status(404).body(ApiResponse
                        .notfound("commentInQuestions not found"));
            }
        } catch (Exception ex) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
        }
    }

    @GetMapping("/comment/replyInParent/{id}")
    public ResponseEntity<?> getCommentInBlog(@PathVariable Long id) {
        try {
            List<Comment>  commentInParent = commentService.getReplies(id);
            return ResponseEntity.ok(ApiResponse.success(commentInParent, "get comment reply In comment Parent successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    @PutMapping("/comment/update")
    public ResponseEntity<?> updateComment(@PathVariable Long id,@RequestBody CommentDTO commentDTO,
                                           BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Comment updateComment = commentService.updateCommentForum(id,commentDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(updateComment,"update Comment successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @DeleteMapping("/deleteComment/{id}")
    public void deleteComment(@PathVariable Long id) {
        commentService.deleteCommentForum(id);
    }

    @PutMapping("/comment/changePublished/{id}")
    public ResponseEntity<?> changePublished(@PathVariable Long id, @RequestBody ChangeStatusCommentDTO changeStatusCommentDTO,
                                           BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Comment changePublished = commentService.changeStatusCMF(id,changeStatusCommentDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(changePublished,"change Published successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
}
