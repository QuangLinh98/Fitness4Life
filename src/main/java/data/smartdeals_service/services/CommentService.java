package data.smartdeals_service.services;

import data.smartdeals_service.dto.CreateCommentOriginDTO;
import data.smartdeals_service.dto.CreateReplyDTO;
import data.smartdeals_service.models.Blog;
import data.smartdeals_service.models.Comment;
import data.smartdeals_service.repository.BlogRepository;
import data.smartdeals_service.repository.CommentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CommentService {
    private final CommentRepository commentRepository;
    private final BlogRepository blogRepository;

    // 1. Lấy tất cả bình luận
    public List<Comment> getAllComments() {
        return commentRepository.findAll();
    }

    // 2. Tìm bình luận theo id
    public Optional<Comment> findCommentById(Long id) {
        return commentRepository.findById(id);
    }

    // 3. Tìm tất cả bình luận của một bài blog
    public List<Comment> findCommentsByBlog(Long blogId) {
        return commentRepository.findByBlogId(blogId);
    }

    public Comment createCommentCha(CreateCommentOriginDTO createCommentOriginDTO) {
        // Kiểm tra blog tồn tại
        Optional<Blog> blog = blogRepository.findById(createCommentOriginDTO.getBlogId());
        if (!blog.isPresent()) {
            throw new IllegalArgumentException("Bài blog không tồn tại");
        }

        // Tạo bình luận
        Comment comment = new Comment();
        comment.setBlog(blog.get());
        comment.setContent(createCommentOriginDTO.getContent());
        comment.setAuthorId(createCommentOriginDTO.getAuthorId());
        comment.setAuthorName(createCommentOriginDTO.getAuthorName());
        comment.setIsPublished(true);
        comment.setCreatedAt(LocalDateTime.now());
        comment.setUpdatedAt(null);
        comment.setParentComment(null); // Bình luận cha sẽ không có parentComment

        return commentRepository.save(comment);
    }

    public Comment createCommentCon(CreateReplyDTO createReplyDTO) {
        // Kiểm tra blog tồn tại
        Optional<Blog> blog = blogRepository.findById(createReplyDTO.getBlogId());
        if (!blog.isPresent()) {
            throw new IllegalArgumentException("Bài blog không tồn tại");
        }

        // Kiểm tra bình luận cha
        Optional<Comment> parentComment = commentRepository.findById(createReplyDTO.getParentCommentId());
        if (!parentComment.isPresent()) {
            throw new IllegalArgumentException("Bình luận cha không tồn tại");
        }

        // Tạo bình luận con
        Comment comment = new Comment();
        comment.setBlog(blog.get());
        comment.setContent(createReplyDTO.getContent());
        comment.setAuthorId(createReplyDTO.getAuthorId());
        comment.setAuthorName(createReplyDTO.getAuthorName());
        comment.setIsPublished(true);
        comment.setParentComment(parentComment.get()); // Liên kết với bình luận cha
        comment.setCreatedAt(LocalDateTime.now());
        comment.setUpdatedAt(null);

        return commentRepository.save(comment);
    }

}

