package data.smartdeals_service.services.commentServices;

import data.smartdeals_service.dto.comment.ChangeStatusCommentDTO;
import data.smartdeals_service.dto.comment.CommentDTO;
import data.smartdeals_service.models.blog.Blog;
import data.smartdeals_service.models.comment.Comment;
import data.smartdeals_service.models.forum.Question;
import data.smartdeals_service.repository.blogRepositories.BlogRepository;
import data.smartdeals_service.repository.commentRepositories.CommentRepository;
import data.smartdeals_service.repository.forumRepositories.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
@Service
@RequiredArgsConstructor
public class CommentService {
    private final BlogRepository blogRepository;
    private final CommentRepository commentRepository;
    private final QuestionRepository questionRepository;
    //=========================blog=========================

    public List<Comment> getAllComments() {
        return commentRepository.findAll();
    }

    public Optional<Comment> findCommentById(Long id) {
        return commentRepository.findById(id);
    }

    public List<Comment> findCommentsByBlog(Long blogId) {
        return commentRepository.findByBlogId(blogId);
    }

    public Comment createCommentBlog(CommentDTO commentDTO) {
        Comment comment = new Comment();
        comment.setContent(commentDTO.getContent());
        comment.setUserId(commentDTO.getUserId());
        comment.setUserName(commentDTO.getUserName());
        comment.setIsPublished(true);
        comment.setCreatedAt(LocalDateTime.now());
        comment.setUpdatedAt(null);

        // kiểm tra blog có tồn tại ko
        if (commentDTO.getBlogId() != null) {
            Blog blogs = blogRepository.findById(commentDTO.getBlogId())
                    .orElseThrow(() -> new RuntimeException("blogs not found"));
            comment.setBlog(blogs);
        }
        // Kiểm tra bình luận cha
        if (commentDTO.getParentCommentId() != null) {
            Comment Comments = commentRepository.findById(commentDTO.getParentCommentId())
                    .orElseThrow(() -> new RuntimeException("Comments not found"));
            comment.setParentComment(Comments);
        }
        return commentRepository.save(comment);
    }

    public Comment updateComment(Long id, CommentDTO commentDTO) {
        Comment commentFindById = commentRepository.findById(id).orElse(null);
        // Kiểm tra blog tồn tại
        Optional<Blog> blogs = blogRepository.findById(commentDTO.getBlogId());
        if (!blogs.isPresent()) {
            throw new IllegalArgumentException("Bài blog không tồn tại");
        }
        // Kiểm tra bình luận cha
        Optional<Comment> parentComment = commentRepository.findById(commentDTO.getParentCommentId());
        if (!parentComment.isPresent()) {
            throw new IllegalArgumentException("Bình luận cha không tồn tại");
        }

        commentFindById.setBlog(blogs.get());
        commentFindById.setContent(commentDTO.getContent());
        commentFindById.setUserId(commentDTO.getUserId());
        commentFindById.setUserName(commentDTO.getUserName());
        commentFindById.setParentComment(parentComment.get()); // Liên kết với bình luận cha
        commentFindById.setUpdatedAt(LocalDateTime.now());

        return commentRepository.save(commentFindById);
    }

    public void deleteComment(Long id) {
        commentRepository.deleteById(id);
    }
    // Phương thức cập nhật trạng thái
    public Comment changeStatusCMB(Long id, ChangeStatusCommentDTO status) {
        Comment comments = commentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("comments not found with id: " + id));
        comments.setIsPublished(status.getIsPublished());
        return commentRepository.save(comments);
    }

    //=================forum============================

    public Comment createCommentForum(CommentDTO commentDTO) {
        Comment comment = new Comment();
        comment.setUserId(commentDTO.getUserId());
        comment.setContent(commentDTO.getContent());
        comment.setUserName(commentDTO.getUserName());
        comment.setCreatedAt(LocalDateTime.now());
        comment.setIsPublished(true);
        comment.setUpdatedAt(null);

        // kiểm tra câu hỏi có tồn tại ko
        if (commentDTO.getQuestionId() != null) {
            Question question = questionRepository.findById(commentDTO.getQuestionId())
                    .orElseThrow(() -> new RuntimeException("Question not found"));
            comment.setQuestion(question);
        }
        if (commentDTO.getParentCommentId() != null) {
            Comment parentComment = commentRepository.findById(commentDTO.getParentCommentId())
                    .orElseThrow(() -> new RuntimeException("Parent comment not found"));
            comment.setParentComment(parentComment);
        }
        return commentRepository.save(comment);
    }

    public Comment updateCommentForum(Long id,CommentDTO commentDTO) {

        Comment commentById = commentRepository.findById(id).orElse(null);
        commentById.setUserId(commentDTO.getUserId());
        commentById.setContent(commentDTO.getContent());
        commentById.setUserName(commentDTO.getUserName());
        commentById.setUpdatedAt(LocalDateTime.now());
        // kiểm tra câu hỏi có tồn tại ko
        if (commentDTO.getQuestionId() != null) {
            Question question = questionRepository.findById(commentDTO.getQuestionId())
                    .orElseThrow(() -> new RuntimeException("Question not found"));
            commentById.setQuestion(question);
        }
        if (commentDTO.getParentCommentId() != null) {
            Comment parentComment = commentRepository.findById(commentDTO.getParentCommentId())
                    .orElseThrow(() -> new RuntimeException("Parent comment not found"));
            commentById.setParentComment(parentComment);
        }
        return commentRepository.save(commentById);
    }
    public void deleteCommentForum(Long id) {
        commentRepository.deleteById(id);
    }
    public List<Comment> getCommentsByQuestion(Long questionId) {
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("Question not found"));
        return commentRepository.findByQuestionAndParentCommentIsNull(question);
    }
    // Lấy tất cả các bình luận con của một bình luận cha
    public List<Comment> getReplies(Long parentCommentId) {
        Comment parentComment = commentRepository.findById(parentCommentId)
                .orElseThrow(() -> new RuntimeException("Parent comment not found"));
        return commentRepository.findByParentComment(parentComment);
    }
    // Phương thức cập nhật trạng thái
    public Comment changeStatusCMF(Long id,ChangeStatusCommentDTO status) {
        Comment comments = commentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("comments not found with id: " + id));
        comments.setIsPublished(status.getIsPublished());
        return commentRepository.save(comments);
    }
}
