package data.smartdeals_service.controller;

import data.smartdeals_service.dto.CreateCommentOriginDTO;
import data.smartdeals_service.dto.CreateReplyDTO;
import data.smartdeals_service.helpers.ApiResponse;
import data.smartdeals_service.models.Comment;
import data.smartdeals_service.services.CommentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/comments")
@RequiredArgsConstructor
public class CommentController {
    private final CommentService commentService;

    @GetMapping("/")
    public ResponseEntity<?> getAllComments() {
        try {
            List<Comment>  comments = commentService.getAllComments();
            return ResponseEntity.ok(ApiResponse.success(comments, "get all comment successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getCommentById(@PathVariable Long id) {
        try {
            Optional<Comment> comment = commentService.findCommentById(id);
            if (comment != null) {
                return ResponseEntity.status(200).body(ApiResponse
                        .success(comment, "get one comment successfully"));
            } else {
                return ResponseEntity.status(404).body(ApiResponse
                        .notfound("blog not found"));
            }
        } catch (Exception ex) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
        }
    }

    @GetMapping("/blog/{blogId}")
    public ResponseEntity<?> getCommentsByBlog(@PathVariable Long blogId) {
        try {
            List<Comment>  commentInBlog = commentService.findCommentsByBlog(blogId);
            return ResponseEntity.ok(ApiResponse.success(commentInBlog, "get comment In Blog successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    @PostMapping("/blog/create")
    public ResponseEntity<?> createCommentCha(@Valid @RequestBody CreateCommentOriginDTO comment,
                                              BindingResult bindingResult)
    {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Comment createdComment = commentService.createCommentCha(comment);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(createdComment,"create Comment successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    @PostMapping("/blog/parent/create")
    public ResponseEntity<?> createCommentCon(@Valid @RequestBody CreateReplyDTO reply,
                                              BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Comment createdReply = commentService.createCommentCon(reply);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(createdReply,"create reply successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
}
