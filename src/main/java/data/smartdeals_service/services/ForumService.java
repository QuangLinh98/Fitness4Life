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

    public Question createQuestion(CreateQuestionDTO questionDTO) {
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
}
