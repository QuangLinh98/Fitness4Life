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


}
