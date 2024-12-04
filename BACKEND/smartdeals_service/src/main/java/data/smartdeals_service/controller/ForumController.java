package data.smartdeals_service.controller;

import data.smartdeals_service.helpers.ApiResponse;
import data.smartdeals_service.models.Comment;
import data.smartdeals_service.models.Question;
import data.smartdeals_service.services.ForumService;
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
    private final ForumService forumService;
    @GetMapping("/questions")
    public ResponseEntity<?> getAllQuestion() {
        try {
            List<Question> questions = forumService.findAll();
            return ResponseEntity.ok(ApiResponse.success(questions, "get all questions successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @GetMapping("/questions/{id}")
    public ResponseEntity<?> getQuestionById(@PathVariable Long id) {
        try {
            Optional<Question> questions = forumService.findById(id);
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
            Question savedQuestion = forumService.createQuestion(questionDTO);
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
            Question updateQuestion = forumService.updateQuestion(id,questionDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(updateQuestion,"update Question  successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @DeleteMapping("/{id}")
    public void deleteQuestion(@PathVariable Long id) {
        forumService.deleteQuestion(id);
    }
    // Tạo bình luận hoặc trả lời bình luận
    @PostMapping("/comment/create")
    public ResponseEntity<?> createComment(@RequestBody CommentDTO commentDTO,
                                           BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Comment savedComment = forumService.createCommentForum(commentDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(savedComment,"create Comment successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    // Lấy danh sách bình luận theo câu hỏi
    @GetMapping("/commentFlowerQuestions/{questionId}")
    public ResponseEntity<?> getCommentsByQuestion(@PathVariable Long questionId) {
        try {
            List<Comment> commentInQuestions = forumService.getCommentsByQuestion(questionId);
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
            List<Comment>  commentInParent = forumService.getReplies(id);
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
            Comment updateComment = forumService.updateCommentForum(id,commentDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(updateComment,"update Comment successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @DeleteMapping("/{id}")
    public void deleteComment(@PathVariable Long id) {
        forumService.deleteCommentForum(id);
    }

    @PutMapping("/comment/changePublished/{id}")
    public ResponseEntity<?> updateComment(@PathVariable Long id, @RequestBody ChangeStatusCommentDTO changeStatusCommentDTO,
                                           BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Comment changePublished = forumService.changeStatusCMF(id,changeStatusCommentDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(changePublished,"change Published successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
}
