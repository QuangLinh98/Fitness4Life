package data.smartdeals_service.services;

import data.smartdeals_service.dto.*;
import data.smartdeals_service.models.*;
import data.smartdeals_service.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ForumService {
    private final CommentRepository commentRepository;
    private final QuestionRepository questionRepository;

    public Question createQuestion(QuestionDTO questionDTO) {
        Question question = new Question();
        question.setTitle(questionDTO.getTitle());
        question.setContent(questionDTO.getContent());
        question.setAuthor(questionDTO.getAuthor());
        question.setCreatedAt(LocalDateTime.now());
        questionRepository.save(question);
        return question;
    }
    public List<Question> findAll() {
        return questionRepository.findAll();
    }
    public Optional<Question> findById(Long id) {
        return questionRepository.findById(id);
    }

    public Question updateQuestion(Long id, QuestionDTO questionDTO) {
        Question questionById = questionRepository.findById(id).orElse(null);
        questionById.setTitle(questionDTO.getTitle());
        questionById.setContent(questionDTO.getContent());
        questionById.setAuthor(questionDTO.getAuthor());
        questionById.setUpdatedAt(LocalDateTime.now());
        return questionRepository.save(questionById);
    }

    public void deleteQuestion(Long id) {
        questionRepository.deleteById(id);
    }

    public Comment createCommentForum(CommentDTO commentDTO) {
        Comment comment = new Comment();
        comment.setUserId(commentDTO.getUserId());
        comment.setContent(commentDTO.getContent());
        comment.setUserName(commentDTO.getUserName());
        comment.setCreatedAt(LocalDateTime.now());
        comment.setIsPublished(true);

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
