package data.smartdeals_service.services;

import data.smartdeals_service.dto.CreateCommentForumDTO;
import data.smartdeals_service.dto.CreateQuestionDTO;
import data.smartdeals_service.models.CommentForum;
import data.smartdeals_service.models.Question;
import data.smartdeals_service.repository.CommentForumRepository;
import data.smartdeals_service.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ForumService {
    private final CommentForumRepository commentForumRepository;
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

    public CommentForum createComment(CreateCommentForumDTO createCommentForumDTO) {
        CommentForum comment = new CommentForum();
        comment.setContent(createCommentForumDTO.getContent());
        comment.setAuthor(createCommentForumDTO.getAuthor());
        comment.setCreatedAt(LocalDateTime.now());

        // Gán câu hỏi hoặc bình luận cha
        if (createCommentForumDTO.getQuestionId() != null) {
            Question question = questionRepository.findById(createCommentForumDTO.getQuestionId())
                    .orElseThrow(() -> new RuntimeException("Question not found"));
            comment.setQuestion(question);
        }
        if (createCommentForumDTO.getParentId() != null) {
            CommentForum parentComment = commentForumRepository.findById(createCommentForumDTO.getParentId())
                    .orElseThrow(() -> new RuntimeException("Parent comment not found"));
            comment.setParentComment(parentComment);
        }
        return commentForumRepository.save(comment);
    }
    public List<CommentForum> getCommentsByQuestion(Long questionId) {
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("Question not found"));
        return commentForumRepository.findByQuestionAndParentCommentIsNull(question);
    }
    // Lấy tất cả các bình luận con của một bình luận cha
    public List<CommentForum> getReplies(Long parentCommentId) {
        CommentForum parentComment = commentForumRepository.findById(parentCommentId)
                .orElseThrow(() -> new RuntimeException("Parent comment not found"));
        return commentForumRepository.findByParentComment(parentComment);
    }
}
