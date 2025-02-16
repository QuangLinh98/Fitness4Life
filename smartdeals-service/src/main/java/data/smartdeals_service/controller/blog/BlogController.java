//package data.smartdeals_service.controller.blog;
//
//import data.smartdeals_service.dto.blog.CreateBlogDTO;
//import data.smartdeals_service.dto.blog.UpdateBlogDTO;
//import data.smartdeals_service.dto.comment.ChangeStatusCommentDTO;
//import data.smartdeals_service.dto.comment.CommentDTO;
//import data.smartdeals_service.helpers.ApiResponse;
//import data.smartdeals_service.models.blog.Blog;
//import data.smartdeals_service.models.comment.Comment;
//import data.smartdeals_service.services.blogServices.BlogService;
//import data.smartdeals_service.services.kafkaServices.CommentProducer;
//import data.smartdeals_service.services.commentServices.CommentService;
//import data.smartdeals_service.services.spam.SpamFilterService;
//import jakarta.validation.Valid;
//import lombok.RequiredArgsConstructor;
//import org.springframework.http.HttpStatus;
//import org.springframework.http.ResponseEntity;
//import org.springframework.validation.BindingResult;
//import org.springframework.web.bind.annotation.*;
//
//
//import java.io.IOException;
//import java.util.List;
//import java.util.Optional;
//
//@RestController
//@RequiredArgsConstructor
//@RequestMapping("/api/blogs")
//
//public class BlogController {
//    private final BlogService blogService;
//    private final CommentService commentService;
//    private final CommentProducer commentProducer;
//    private final SpamFilterService spamFilterService;
//
//    @GetMapping
//    public ResponseEntity<?> getAllBlog() {
//        try {
//            List<Blog> products = blogService.findAll();
//            return ResponseEntity.ok(ApiResponse.success(products, "get all blog successfully"));
//        } catch (Exception ex) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
//                    .body(ApiResponse.errorServer("error server"));
//        }
//    }
//    @GetMapping("/{id}")
//    public ResponseEntity<?> getBlogById(@PathVariable Long id) {
//        try {
//            Optional<Blog> blogs = blogService.findById(id);
//            if (blogs != null) {
//                return ResponseEntity.status(200).body(ApiResponse
//                        .success(blogs, "get one blog successfully"));
//            } else {
//                return ResponseEntity.status(404).body(ApiResponse
//                        .notfound("blog not found"));
//            }
//        } catch (Exception ex) {
//            return ResponseEntity.status(500).body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
//        }
//    }
//
//    @PostMapping("/create")
//    public ResponseEntity<?> createBlog(@Valid @ModelAttribute CreateBlogDTO createBlogDTO,
//                                           BindingResult bindingResult) {
//        try {
//            if (bindingResult.hasErrors()) {
//                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
//            }
//            Blog savedBlog = blogService.CreateBlog(createBlogDTO);
//            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
//                    .created(savedBlog,"create blog successfully"));
//        } catch (IOException e) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
//                    .body(ApiResponse.errorServer("error server"));
//        }
//    }
//    @PutMapping("/update/{id}")
//    public ResponseEntity<?> updateBlog(@PathVariable Long id,
//                                        @Valid @ModelAttribute
//                                        UpdateBlogDTO updateBlogDTO,
//                                        BindingResult bindingResult)
//    {
//        try {
//            updateBlogDTO.setId(id);
//            Blog editedBlog = blogService.UpdateBlog(id,updateBlogDTO);
//            if (bindingResult.hasErrors()) {
//                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
//            }
//            if(editedBlog == null){
//                return ResponseEntity.status(HttpStatus.NOT_FOUND)
//                        .body(ApiResponse.notfound(null,"blog not found"));
//            }
//            return  ResponseEntity.status(HttpStatus.OK).body(ApiResponse
//                    .success(editedBlog,"update blog successfully"));
//        } catch (Exception e) {
//            e.printStackTrace();
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
//                    .body(ApiResponse.errorServer("error server" + e.getMessage()));
//        }
//    }
//
//    @DeleteMapping("/deleteBlog/{id}")
//    public ResponseEntity<ApiResponse<?>> deleteBlog(@PathVariable Long id){
//        try {
//            Optional<Blog> blogExisting = blogService.findById(id);
//            if(blogExisting.isEmpty()){
//                return ResponseEntity.status(HttpStatus.NOT_FOUND)
//                        .body(ApiResponse.notfound(null,"blog not found"));
//            }else{
//                blogService.deleteBlogById(id);
//                return ResponseEntity.ok(ApiResponse.success(blogExisting.get(),
//                        "delete blog successfully"));
//            }
//        }catch (Exception ex) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
//                    .body(ApiResponse.errorServer("error server" + ex.getMessage()));
//        }
//    }
//
//    @GetMapping("/comment")
//    public ResponseEntity<?> getAllComments() {
//        try {
//            List<CommentDTO>  comments = commentService.getAllComments();
//            return ResponseEntity.ok(ApiResponse.success(comments, "get all comment successfully"));
//        } catch (Exception ex) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
//                    .body(ApiResponse.errorServer("error server"));
//        }
//    }
//
//    @GetMapping("/comment{id}")
//    public ResponseEntity<?> getCommentById(@PathVariable Long id) {
//        try {
//            Optional<Comment> comment = commentService.findCommentById(id);
//            if (comment != null) {
//                return ResponseEntity.status(200).body(ApiResponse
//                        .success(comment, "get one comment successfully"));
//            } else {
//                return ResponseEntity.status(404).body(ApiResponse
//                        .notfound("blog not found"));
//            }
//        } catch (Exception ex) {
//            return ResponseEntity.status(500).body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
//        }
//    }
//
//    @GetMapping("/commentInBlog/{blogId}")
//    public ResponseEntity<?> getCommentInBlog(@PathVariable Long blogId) {
//        try {
//            List<Comment>  commentInBlog = commentService.findCommentsByBlog(blogId);
//            return ResponseEntity.ok(ApiResponse.success(commentInBlog, "get comment In Blog successfully"));
//        } catch (Exception ex) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
//                    .body(ApiResponse.errorServer("error server"));
//        }
//    }
//
//    @PostMapping("/comment/create")
//    public ResponseEntity<?> createComment(@Valid @RequestBody CommentDTO comment,
//                                              BindingResult bindingResult)
//    {
//        try {
//            String detectedLanguage = spamFilterService.detectLanguage(comment.getContent());
//            if (bindingResult.hasErrors()) {
//                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
//            }
//            if (spamFilterService.isSpam(comment.getContent(),detectedLanguage)) {
//                return ResponseEntity.badRequest().body("Your comment contains spam words and cannot be accepted.");
//            }
//           commentProducer.sendComment(comment);
//            return  ResponseEntity.ok("create Comment successfully");
//        }catch (Exception ex) {
//            if(ex.getMessage().contains("BLOGANDQUESTIONNOTFOUND")) {
//                return ResponseEntity.status(400).body(ApiResponse.badRequest("blog not found"));
//            }
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
//                    .body(ApiResponse.errorServer("error server"));
//        }
//    }
//
//    @PutMapping("/comment/update/{id}")
//    public ResponseEntity<?> updateComment(@PathVariable Long id,@Valid  @RequestBody CommentDTO commentDTO,
//                                         BindingResult bindingResult) {
//        try {
//            if (bindingResult.hasErrors()) {
//                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
//            }
//            Comment updateCommment = commentService.updateComment(id,commentDTO);
//            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
//                    .created(updateCommment,"update Commment successfully"));
//        } catch (Exception e) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
//                    .body(ApiResponse.errorServer("error server"));
//        }
//    }
//    @DeleteMapping("/deleteCommment/{id}")
//    public void deleteComment(@PathVariable Long id) {
//        commentService.deleteComment(id);
//    }
//    @PutMapping("/comment/changePublished/{id}")
//    public ResponseEntity<?> updateComment(@PathVariable Long id, @RequestBody ChangeStatusCommentDTO changeStatusCommentDTO,
//                                           BindingResult bindingResult) {
//        try {
//            if (bindingResult.hasErrors()) {
//                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
//            }
//            Comment changePublished = commentService.changeStatusCMB(id,changeStatusCommentDTO);
//            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
//                    .created(changePublished,"change Published successfully"));
//        } catch (Exception e) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
//                    .body(ApiResponse.errorServer("error server"));
//        }
//    }
//}
//
package data.smartdeals_service.controller.blog;

import data.smartdeals_service.dto.blog.CreateBlogDTO;
import data.smartdeals_service.dto.blog.UpdateBlogDTO;
import data.smartdeals_service.dto.comment.ChangeStatusCommentDTO;
import data.smartdeals_service.dto.comment.CommentDTO;
import data.smartdeals_service.dto.comment.GetCommentDTO;
import data.smartdeals_service.helpers.ApiResponse;
import data.smartdeals_service.models.blog.Blog;
import data.smartdeals_service.models.comment.Comment;
import data.smartdeals_service.models.forum.Question;
import data.smartdeals_service.services.blogServices.BlogService;
import data.smartdeals_service.services.kafkaServices.CommentConsumer;
import data.smartdeals_service.services.kafkaServices.CommentProducer;
import data.smartdeals_service.services.commentServices.CommentService;
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
import java.util.concurrent.CompletableFuture;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/deal/blogs")
public class BlogController {
    private final BlogService blogService;
    private final CommentService commentService;
    private final CommentProducer commentProducer;
    private final SpamFilterService spamFilterService;

    @GetMapping
    public ResponseEntity<?> getAllBlog() {
        try {
            List<Blog> products = blogService.findAll();
            return ResponseEntity.ok(ApiResponse.success(products, "Get all blogs successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getBlogById(@PathVariable Long id) {
        try {
            Optional<Blog> blogs = blogService.findById(id);
            return blogs.map(blog -> ResponseEntity.ok(ApiResponse.success(blog, "Get one blog successfully")))
                    .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).body(ApiResponse.notfound("Blog not found")));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
        }
    }

    @PostMapping("/create")
    public ResponseEntity<?> createBlog(@Valid @ModelAttribute CreateBlogDTO createBlogDTO, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            Blog savedBlog = blogService.CreateBlog(createBlogDTO);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.created(savedBlog, "Create blog successfully"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + e.getMessage()));
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<?> updateBlog(@PathVariable Long id, @Valid @ModelAttribute UpdateBlogDTO updateBlogDTO, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            updateBlogDTO.setId(id);
            Blog editedBlog = blogService.UpdateBlog(id, updateBlogDTO);
            return ResponseEntity.ok(ApiResponse.success(editedBlog, "Update blog successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + e.getMessage()));
        }
    }

    @DeleteMapping("/deleteBlog/{id}")
    public ResponseEntity<ApiResponse<?>> deleteBlog(@PathVariable Long id) {
        try {
            Optional<Blog> blogExisting = blogService.findById(id);
            if (blogExisting.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.notfound(null, "Blog not found"));
            }
            blogService.deleteBlogById(id);
            return ResponseEntity.ok(ApiResponse.success(blogExisting.get(), "Delete blog successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @GetMapping("/comment")
    public ResponseEntity<?> getAllComments() {
        try {
            List<CommentDTO> comments = commentService.getAllComments();
            return ResponseEntity.ok(ApiResponse.success(comments, "Get all comments successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @GetMapping("/comment/{id}")
    public ResponseEntity<?> getCommentById(@PathVariable Long id) {
        try {
            Optional<CommentDTO> comment = commentService.findCommentById(id);
            return comment.map(value -> ResponseEntity.ok(ApiResponse.success(value, "Get one comment successfully")))
                    .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).body(ApiResponse.notfound("Comment not found")));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @GetMapping("/commentInBlog/{blogId}")
    public ResponseEntity<?> getCommentInBlog(@PathVariable Long blogId) {
        try {
            List<CommentDTO> commentInBlog = commentService.findCommentsByBlog(blogId);
            return ResponseEntity.ok(ApiResponse.success(commentInBlog, "Get comments in blog successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @PostMapping("/comment/create")
    public ResponseEntity<?> createComment(@Valid @RequestBody CommentDTO comment, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            String detectedLanguage = spamFilterService.detectLanguage(comment.getContent());
            if (spamFilterService.isSpam(comment.getContent(), detectedLanguage)) {
                return ResponseEntity.badRequest().body("Your comment contains spam words and cannot be accepted.");
            }
            Optional<Blog> blogId = blogService.findById(comment.getBlogId());
            if(blogId.isPresent()) {
                commentProducer.sendComment(comment);
                return ResponseEntity.ok(ApiResponse.success(null, "Create comment successfully"));
            }else {
                return ResponseEntity.badRequest().body("Blog by Id Not Found");
            }
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @PutMapping("/comment/update/{id}")
    public ResponseEntity<?> updateComment(@PathVariable Long id, @Valid @RequestBody CommentDTO commentDTO, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            Comment updatedComment = commentService.updateComment(id, commentDTO);
            return ResponseEntity.ok(ApiResponse.success(updatedComment, "Update comment successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @DeleteMapping("/comment/{id}")
    public ResponseEntity<?> deleteComment(@PathVariable Long id) {
        try {
            commentService.deleteComment(id);
            return ResponseEntity.ok(ApiResponse.success(null, "Delete comment successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @PutMapping("/comment/changePublished/{id}")
    public ResponseEntity<?> changePublishedStatus(@PathVariable Long id, @RequestBody ChangeStatusCommentDTO changeStatusCommentDTO, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            Comment updatedStatus = commentService.changeStatusCMB(id, changeStatusCommentDTO);
            return ResponseEntity.ok(ApiResponse.success(updatedStatus, "Change comment published status successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }
    @GetMapping("/blog/{blogId}/comment")
    public ResponseEntity<List<GetCommentDTO>> getCommentsByBlog(@PathVariable Long blogId) {
        List<GetCommentDTO> comments = commentService.getCommentsByBlogId(blogId);
        return ResponseEntity.ok(comments);
    }
}
