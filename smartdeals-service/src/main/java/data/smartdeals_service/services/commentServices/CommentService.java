
package data.smartdeals_service.services.commentServices;

import data.smartdeals_service.dto.comment.ChangeStatusCommentDTO;
import data.smartdeals_service.dto.comment.CommentDTO;
import data.smartdeals_service.dto.comment.GetCommentDTO;
import data.smartdeals_service.helpers.EmojiUtils;
import data.smartdeals_service.models.blog.Blog;
import data.smartdeals_service.models.comment.Comment;
import data.smartdeals_service.models.forum.Question;
import data.smartdeals_service.repository.blogRepositories.BlogRepository;
import data.smartdeals_service.repository.commentRepositories.CommentRepository;
import data.smartdeals_service.repository.forumRepositories.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CommentService {
    private final BlogRepository blogRepository;
    private final CommentRepository commentRepository;
    private final QuestionRepository questionRepository;

    //========================= Generic Helper =========================

    private CommentDTO convertToCommentDTOWithReplies(Comment comment) {
        CommentDTO dto = new CommentDTO();
        dto.setId(comment.getId());
        dto.setContent(EmojiUtils.unicodeToEmoji(comment.getContent())); // Chuyển Unicode thành emoji
        dto.setUserName(comment.getUserName());
        dto.setUserId(comment.getUserId());
        dto.setQuestionId(comment.getQuestion() != null ? comment.getQuestion().getId() : null);
        dto.setBlogId(comment.getBlog() != null ? comment.getBlog().getId() : null);
        dto.setParentCommentId(comment.getParentComment() != null ? comment.getParentComment().getId() : null);
        dto.setCreatedAt(comment.getCreatedAt());
        dto.setIsPublished(comment.getIsPublished());

        // Đệ quy xử lý replies (nếu có)
        if (comment.getReplies() != null && !comment.getReplies().isEmpty()) {
            List<CommentDTO> replyDTOs = comment.getReplies().stream()
                    .map(this::convertToCommentDTOWithReplies) // Gọi đệ quy để xử lý các reply con
                    .collect(Collectors.toList());
            dto.setReplies(replyDTOs);
        } else {
            dto.setReplies(null);
        }

        return dto;
    }
    //=========================blog=========================

    public List<CommentDTO> getAllComments() {
        return commentRepository.findAll().stream()
                .map(this::convertToCommentDTOWithReplies) // Sử dụng phương thức đệ quy để xây dựng cấu trúc cây
                .collect(Collectors.toList());
    }

    public Optional<CommentDTO> findCommentById(Long id) {
        return commentRepository.findById(id)
                .map(this::convertToCommentDTOWithReplies);
    }

    public List<CommentDTO> findCommentsByBlog(Long blogId) {
        return commentRepository.findByBlogId(blogId).stream()
                .map(this::convertToCommentDTOWithReplies)
                .collect(Collectors.toList());
    }
    public List<GetCommentDTO> getCommentsByBlogId(Long blogId) {
        List<Comment> comments = commentRepository.findCommentsByBlogId(blogId);
        return comments.stream().map(GetCommentDTO::new).collect(Collectors.toList());
    }

    public Comment createCommentBlog(CommentDTO commentDTO) {
        Comment comment = new Comment();
        comment.setContent(EmojiUtils.emojiToUnicode(commentDTO.getContent())); // Chuyển emoji thành Unicode
        comment.setUserId(commentDTO.getUserId());
        comment.setUserName(commentDTO.getUserName());
        comment.setIsPublished(true);
        comment.setCreatedAt(LocalDateTime.now());
        comment.setUpdatedAt(null);

        // kiểm tra blog có tồn tại ko
        if (commentDTO.getBlogId() != null) {
            Blog blogs = blogRepository.findById(commentDTO.getBlogId()).orElse(null);
            comment.setBlog(blogs);
        }
        // Kiểm tra bình luận cha
        if (commentDTO.getParentCommentId() != null) {
            Comment parentComment = commentRepository.findById(commentDTO.getParentCommentId()).orElse(null);
            comment.setParentComment(parentComment);
        }
        return commentRepository.save(comment);
    }

    public Comment updateComment(Long id, CommentDTO commentDTO) {
        Comment commentFindById = commentRepository.findById(id).orElse(null);
        if (commentFindById == null) {
            throw new RuntimeException("CommentNotFound");
        }

        commentFindById.setContent(EmojiUtils.emojiToUnicode(commentDTO.getContent()));
        commentFindById.setUserId(commentDTO.getUserId());
        commentFindById.setUserName(commentDTO.getUserName());
        commentFindById.setUpdatedAt(LocalDateTime.now());

        // Kiểm tra blog tồn tại
        if (commentDTO.getBlogId() != null) {
            Blog blog = blogRepository.findById(commentDTO.getBlogId())
                    .orElseThrow(() -> new RuntimeException("BlogNotFound"));
            commentFindById.setBlog(blog);
        }

        // Kiểm tra bình luận cha
        if (commentDTO.getParentCommentId() != null) {
            Comment parentComment = commentRepository.findById(commentDTO.getParentCommentId())
                    .orElseThrow(() -> new RuntimeException("ParentCommentNotFound"));
            commentFindById.setParentComment(parentComment);
        }

        return commentRepository.save(commentFindById);
    }

    public void deleteComment(Long id) {
        commentRepository.deleteById(id);
    }

    public Comment changeStatusCMB(Long id, ChangeStatusCommentDTO status) {
        Comment comment = commentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("CommentNotFoundWithId"));
        comment.setIsPublished(status.getIsPublished());
        return commentRepository.save(comment);
    }

    //=================forum============================

    public List<CommentDTO> getAllCommentsForum() {
        return commentRepository.findAll().stream()
                .map(comment -> {
                    CommentDTO dto = new CommentDTO();
                    dto.setId(comment.getId());
                    dto.setContent(EmojiUtils.unicodeToEmoji(comment.getContent())); // Chuyển Unicode thành emoji
                    dto.setUserName(comment.getUserName());
                    dto.setCreatedAt(comment.getCreatedAt());
                    dto.setIsPublished(comment.getIsPublished());
                    return dto;
                })
                .collect(Collectors.toList());
    }

    public Comment createCommentForum(CommentDTO commentDTO) {
        Comment comment = new Comment();
        comment.setContent(EmojiUtils.emojiToUnicode(commentDTO.getContent())); // Chuyển emoji thành Unicode
        comment.setUserId(commentDTO.getUserId());
        comment.setUserName(commentDTO.getUserName());
        comment.setCreatedAt(LocalDateTime.now());
        comment.setIsPublished(true);
        comment.setUpdatedAt(null);

        // kiểm tra câu hỏi có tồn tại ko
        if (commentDTO.getQuestionId() != null) {
            Question question = questionRepository.findById(commentDTO.getQuestionId())
                    .orElseThrow(() -> new RuntimeException("QuestionNotFound"));
            comment.setQuestion(question);
        }
        if (commentDTO.getParentCommentId() != null) {
            Comment parentComment = commentRepository.findById(commentDTO.getParentCommentId())
                    .orElseThrow(() -> new RuntimeException("ParentCommentNotFound"));
            comment.setParentComment(parentComment);
        }
        return commentRepository.save(comment);
    }

    public Comment updateCommentForum(Long id, CommentDTO commentDTO) {
        Comment commentById = commentRepository.findById(id).orElse(null);
        if (commentById == null) {
            throw new RuntimeException("CommentNotFound");
        }

        // Kiểm tra thời gian createdAt so với thời gian hiện tại
        if (commentById.getCreatedAt() != null &&
                Duration.between(commentById.getCreatedAt(), LocalDateTime.now()).toHours() > 24) {
            throw new RuntimeException("CommentCannotBeUpdatedAfter24Hours");
        }
        commentById.setContent(EmojiUtils.emojiToUnicode(commentDTO.getContent()));
        commentById.setUserId(commentDTO.getUserId());
        commentById.setUserName(commentDTO.getUserName());
        commentById.setUpdatedAt(LocalDateTime.now());

        // kiểm tra câu hỏi có tồn tại ko
        if (commentDTO.getQuestionId() != null) {
            Question question = questionRepository.findById(commentDTO.getQuestionId())
                    .orElseThrow(() -> new RuntimeException("QuestionNotFound"));
            commentById.setQuestion(question);
        }

        if (commentDTO.getParentCommentId() != null) {
            Comment parentComment = commentRepository.findById(commentDTO.getParentCommentId())
                    .orElseThrow(() -> new RuntimeException("ParentCommentNotFound"));
            commentById.setParentComment(parentComment);
        }

        return commentRepository.save(commentById);
    }

    public void deleteCommentForum(Long id) {
        Comment commentById = commentRepository.findById(id).orElse(null);

        if (commentById == null) {
            throw new RuntimeException("CommentNotFound");
        }

        // Kiểm tra thời gian createdAt so với thời gian hiện tại
        if (commentById.getCreatedAt() != null &&
                Duration.between(commentById.getCreatedAt(), LocalDateTime.now()).toHours() > 24) {
            throw new RuntimeException("CommentCannotBeDeleteAfter24Hours");
        }

        // Lấy tất cả các comment con liên quan
        List<Comment> childComments = commentRepository.findByParentComment(commentById);

        // Đặt parentComment của các comment con thành null
        for (Comment child : childComments) {
            child.setParentComment(null);
        }

        // Lưu các comment con đã cập nhật
        commentRepository.saveAll(childComments);

        commentRepository.deleteById(id);
    }

    public List<CommentDTO> getCommentsByQuestion(Long questionId) {
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("Question not found"));
        return commentRepository.findByQuestionAndParentCommentIsNull(question).stream()
                .map(this::convertToCommentDTOWithReplies)
                .collect(Collectors.toList());
    }

    public List<CommentDTO> getReplies(Long parentCommentId) {
        Comment parentComment = commentRepository.findById(parentCommentId)
                .orElseThrow(() -> new RuntimeException("Parent comment not found"));
        return commentRepository.findByParentComment(parentComment).stream()
                .map(this::convertToCommentDTOWithReplies)
                .collect(Collectors.toList());
    }

    public Comment changeStatusCMF(Long id, ChangeStatusCommentDTO status) {
        Comment comment = commentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("CommentNotFoundWithId"));
        comment.setIsPublished(status.getIsPublished());
        return commentRepository.save(comment);
    }

    public List<GetCommentDTO> getCommentsByQuestionId(Long questionId) {
        List<Comment> comments = commentRepository.findCommentsByQuestionId(questionId);
        return comments.stream()
                .map(comment -> {
                    GetCommentDTO dto = new GetCommentDTO(comment);
                    // Chuyển Unicode trong content thành emoji
                    dto.setContent(EmojiUtils.unicodeToEmoji(comment.getContent()));
                    return dto;
                })
                .collect(Collectors.toList());
    }

}
