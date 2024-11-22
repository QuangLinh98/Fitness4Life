package data.smartdeals_service.controller;

import data.smartdeals_service.dto.*;
import data.smartdeals_service.helpers.ApiResponse;
import data.smartdeals_service.models.Blog;
import data.smartdeals_service.models.Comment;
import data.smartdeals_service.services.BlogService;
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
@RequiredArgsConstructor
@RequestMapping("/api/blogs")

public class BlogController {
    private final BlogService blogService;

    @GetMapping
    public ResponseEntity<?> getAllBlog() {
        try {
            List<Blog> products = blogService.findAll();
            return ResponseEntity.ok(ApiResponse.success(products, "get all blog successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @GetMapping("/{id}")
    public ResponseEntity<?> getBlogById(@PathVariable Long id) {
        try {
            Optional<Blog> blogs = blogService.findById(id);
            if (blogs != null) {
                return ResponseEntity.status(200).body(ApiResponse
                        .success(blogs, "get one blog successfully"));
            } else {
                return ResponseEntity.status(404).body(ApiResponse
                        .notfound("blog not found"));
            }
        } catch (Exception ex) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
        }
    }

    @PostMapping("/create")
    public ResponseEntity<?> createBlog(@Valid @ModelAttribute CreateBlogDTO createBlogDTO,
                                           BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Blog savedBlog = blogService.CreateBlog(createBlogDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(savedBlog,"create blog successfully"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @PutMapping("/update/{id}")
    public ResponseEntity<?> updateBlog(@PathVariable Long id,
                                        @Valid @ModelAttribute
                                        UpdateBlogDTO updateBlogDTO,
                                        BindingResult bindingResult)
    {
        try {
            updateBlogDTO.setId(id);
            Blog editedBlog = blogService.UpdateBlog(id,updateBlogDTO);
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            if(editedBlog == null){
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.notfound(null,"blog not found"));
            }
            return  ResponseEntity.status(HttpStatus.OK).body(ApiResponse
                    .success(editedBlog,"update blog successfully"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server" + e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> deleteBlog(@PathVariable Long id){
        try {
            Optional<Blog> blogExisting = blogService.findById(id);
            if(blogExisting.isEmpty()){
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.notfound(null,"blog not found"));
            }else{
                blogService.deleteBlogById(id);
                return ResponseEntity.ok(ApiResponse.success(blogExisting.get(),
                        "delete blog successfully"));
            }
        }catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server" + ex.getMessage()));
        }
    }

    @GetMapping("/comment")
    public ResponseEntity<?> getAllComments() {
        try {
            List<Comment>  comments = blogService.getAllComments();
            return ResponseEntity.ok(ApiResponse.success(comments, "get all comment successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    @GetMapping("/comment{id}")
    public ResponseEntity<?> getCommentById(@PathVariable Long id) {
        try {
            Optional<Comment> comment = blogService.findCommentById(id);
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

    @GetMapping("/commentInBlog/{blogId}")
    public ResponseEntity<?> getCommentInBlog(@PathVariable Long blogId) {
        try {
            List<Comment>  commentInBlog = blogService.findCommentsByBlog(blogId);
            return ResponseEntity.ok(ApiResponse.success(commentInBlog, "get comment In Blog successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    @PostMapping("/comment/create")
    public ResponseEntity<?> createComment(@Valid @RequestBody CommentDTO comment,
                                              BindingResult bindingResult)
    {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Comment createdComment = blogService.createCommentBlog(comment);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(createdComment,"create Comment successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    @PostMapping("/comment/reply")
    public ResponseEntity<?> createReply(@Valid @RequestBody CommentDTO reply,
                                              BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Comment createdReply = blogService.createReplyBlog(reply);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(createdReply,"create reply successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @PutMapping("/comment/update/{id}")
    public ResponseEntity<?> updateComment(@PathVariable Long id,@Valid  @RequestBody CommentDTO commentDTO,
                                         BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Comment updateCommment = blogService.updateComment(id,commentDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(updateCommment,"update Commment successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @DeleteMapping("/{id}")
    public void deleteComment(@PathVariable Long id) {
        blogService.deleteComment(id);
    }
    @PutMapping("/comment/changePublished/{id}")
    public ResponseEntity<?> updateComment(@PathVariable Long id, @RequestBody ChangeStatusCommentDTO changeStatusCommentDTO,
                                           BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Comment changePublished = blogService.changeStatusCMB(id,changeStatusCommentDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(changePublished,"change Published successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
}

