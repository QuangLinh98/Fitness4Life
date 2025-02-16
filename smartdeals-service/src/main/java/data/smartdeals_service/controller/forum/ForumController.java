package data.smartdeals_service.controller.forum;

import data.smartdeals_service.dto.comment.ChangeStatusCommentDTO;
import data.smartdeals_service.dto.comment.CommentDTO;
import data.smartdeals_service.dto.comment.GetCommentDTO;
import data.smartdeals_service.dto.forum.QuestionDTO;
import data.smartdeals_service.dto.forum.QuestionResponseDTO;
import data.smartdeals_service.dto.forum.QuestionStatusDTO;
import data.smartdeals_service.dto.forum.UpdateQuestionDTO;
import data.smartdeals_service.helpers.ApiResponse;
import data.smartdeals_service.models.comment.Comment;
import data.smartdeals_service.models.forum.Question;
import data.smartdeals_service.models.forum.VoteType;
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

import java.io.IOException;
import java.util.List;
import java.util.Optional;
@RestController
@RequestMapping("/api/deal/forums")
@RequiredArgsConstructor
public class ForumController {
    private final QuestionService questionService;
    private final CommentService commentService;
    private final CommentProducer commentProducer;
    private final SpamFilterService spamFilterService;

    @PostMapping("/{questionId}/vote")
    public ResponseEntity<?> vote(@PathVariable Long questionId,
                                  @RequestParam Long userId,
                                  @RequestParam VoteType voteType) {
        questionService.handleVote(questionId, userId, voteType);
        return ResponseEntity.ok("Vote successfully handled");
    }

    @GetMapping("/{id}/view")
    public ResponseEntity<?> incrementViewCount(@PathVariable Long id, @RequestParam Long userId) {
        try {
            questionService.incrementViewCount(id, userId);
            return ResponseEntity.ok("View count updated successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error updating view count");
        }
    }
    // Lấy tất cả câu hỏi
    @GetMapping("/questions")
    public ResponseEntity<?> getAllQuestions() {
        try {
            List<QuestionResponseDTO> questions = questionService.findAllQuestions();
            return ResponseEntity.ok(ApiResponse.success(questions, "Get all questions successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    // Lấy câu hỏi theo ID
    @GetMapping("/questions/{id}")
    public ResponseEntity<?> getQuestionById(@PathVariable Long id) {
        try {
            Optional<Question> question = questionService.findById(id);
            if (question.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(question, "Get question successfully"));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.notfound("Question not found"));
            }
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
        }
    }

    @GetMapping("/questions/getOne/{id}")
    public ResponseEntity<?> getOneQuestionById(@PathVariable Long id) {
        try {
            Optional<QuestionResponseDTO> question = questionService.getOneQuestionById(id);
            if (question.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(question, "Get question successfully"));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.notfound("Question not found"));
            }
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
        }
    }

    // Tạo câu hỏi
    @PostMapping("/questions/create")
    public ResponseEntity<?> createQuestion(@ModelAttribute @Valid QuestionDTO questionDTO, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            Question savedQuestion = questionService.createQuestion(questionDTO);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.created(savedQuestion, "Create question successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    // Cập nhật câu hỏi
    @PutMapping("/questions/update/{id}")
    public ResponseEntity<?> updateQuestion(@PathVariable Long id, @ModelAttribute UpdateQuestionDTO updateQuestionDTO, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            Question updatedQuestion = questionService.updateQuestion(id,updateQuestionDTO);
            return  ResponseEntity.status(HttpStatus.OK).body(ApiResponse
                    .success(updatedQuestion, "Update question successfully"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server" + e.getMessage()));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server" + e.getMessage()));
        }
    }

    // Xóa câu hỏi
    @DeleteMapping("/questions/delete/{id}")
    public ResponseEntity<?> deleteQuestion(@PathVariable Long id) {
        try {
            questionService.deleteQuestion(id);
            return ResponseEntity.ok(ApiResponse.success(null, "Delete question successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @PutMapping("/Questions/changePublished/{id}")
    public ResponseEntity<?> changePublished(@PathVariable Long id, @RequestBody QuestionStatusDTO status,
                                             BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Question changePublished = questionService.closeQuestionStatus(id,status);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(changePublished,"change Published successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    // Tạo bình luận
    @PostMapping("/comments/create")
    public ResponseEntity<?> createComment(@RequestBody @Valid CommentDTO commentDTO, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            String detectedLanguage = spamFilterService.detectLanguage(commentDTO.getContent());
            if (spamFilterService.isSpam(commentDTO.getContent(), detectedLanguage)) {
                return ResponseEntity.status(402).body("Comment contains spam and cannot be accepted.");
            }
            Optional<Question> questionId = questionService.findById(commentDTO.getQuestionId());
            if (questionId.isPresent()) {
                commentProducer.sendComment(commentDTO); // Gửi bình luận tới Kafka
                return ResponseEntity.ok(ApiResponse.created(null, "Create comment successfully"));
            }else {
                return ResponseEntity.badRequest().body("Question By Id not found");
            }

        } catch (Exception ex) {
            if (ex.getMessage().contains("QuestionNotFound")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("question not found"));
            }
            if (ex.getMessage().contains("ParentCommentNotFound")) {
                return ResponseEntity.status(401).body(ApiResponse.badRequest("Parent Comment Not Found"));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    // get commemt flow question id
    @GetMapping("/question/{questionId}/comment")
    public ResponseEntity<List<GetCommentDTO>> getCommentsByQuestionId(@PathVariable Long questionId) {
        List<GetCommentDTO> comments = commentService.getCommentsByQuestionId(questionId);
        return ResponseEntity.ok(comments);
    }

    // Cập nhật bình luận
    @PutMapping("/comments/update/{id}")
    public ResponseEntity<?> updateComment(@PathVariable Long id, @RequestBody @Valid CommentDTO commentDTO, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            String detectedLanguage = spamFilterService.detectLanguage(commentDTO.getContent());
            if (spamFilterService.isSpam(commentDTO.getContent(), detectedLanguage)) {
                return ResponseEntity.status(403).body("Comment contains spam and cannot be accepted.");
            }

            Comment updatedComment = commentService.updateCommentForum(id, commentDTO);
            return ResponseEntity.ok(ApiResponse.success(updatedComment, "Update comment successfully"));
        } catch (Exception ex) {
            if (ex.getMessage().contains("QuestionNotFound")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("question not found"));
            }
            if (ex.getMessage().contains("ParentCommentNotFound")) {
                return ResponseEntity.status(401).body(ApiResponse.badRequest("Parent Comment Not Found"));
            }
            if (ex.getMessage().contains("CommentCannotBeUpdatedAfter24Hours")) {
                return ResponseEntity.status(402).body(ApiResponse.badRequest("Comment Cannot Be Updated After 24 Hours"));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    // Xóa bình luận
    @DeleteMapping("/comments/delete/{id}")
    public ResponseEntity<?> deleteComment(@PathVariable Long id) {
        try {
            commentService.deleteCommentForum(id);
            return ResponseEntity.ok(ApiResponse.success(null, "Delete comment successfully"));
        } catch (Exception ex) {
            if (ex.getMessage().contains("CommentNotFound")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("comment not found"));
            }
            if (ex.getMessage().contains("CommentCannotBeDeleteAfter24Hours")) {
                return ResponseEntity.status(401).body(ApiResponse.badRequest("Comment Cannot Be Delete After 24 Hours"));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    // Thay đổi trạng thái xuất bản bình luận
    @PutMapping("/comments/change-published/{id}")
    public ResponseEntity<?> changePublished(@PathVariable Long id, @RequestBody ChangeStatusCommentDTO statusDTO, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            Comment updatedComment = commentService.changeStatusCMF(id, statusDTO);
            return ResponseEntity.ok(ApiResponse.success(updatedComment, "Change comment status successfully"));
        } catch (Exception ex) {
            if (ex.getMessage().contains("CommentNotFoundWithId")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("Comment Not Found With Id : " + id));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }
}
