package data.smartdeals_service.services.forumServices;

import data.smartdeals_service.dto.forum.QuestionDTO;
import data.smartdeals_service.dto.forum.QuestionResponseDTO;
import data.smartdeals_service.helpers.FileUploadAvata;
import data.smartdeals_service.helpers.GlobalConstant;
import data.smartdeals_service.models.blog.BlogImage;
import data.smartdeals_service.models.forum.CategoryForum;
import data.smartdeals_service.models.forum.Question;
import data.smartdeals_service.models.forum.QuestionImage;
import data.smartdeals_service.repository.forumRepositories.QuestionImageRepository;
import data.smartdeals_service.repository.forumRepositories.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class QuestionService {
    private final QuestionRepository questionRepository;
    private final QuestionImageRepository questionImageRepository;
    private final FileUploadAvata fileUploadAvata;
    private String subFolder = "QuestionsImage";
    private String urlImage = GlobalConstant.rootUrl
            + GlobalConstant.uploadFolder + File.separator + subFolder;

    public Question createQuestion(QuestionDTO questionDTO) throws IOException {
        Question question = new Question();
        question.setAuthorId(questionDTO.getAuthorId());
        question.setAuthor(questionDTO.getAuthor());
        question.setTitle(questionDTO.getTitle());
        question.setContent(questionDTO.getContent());
        question.setTopic(questionDTO.getTopic());
        question.setTag(questionDTO.getTag());
        if (questionDTO.getCategory() != null) {
            question.setCategory(CategoryForum.valueOf(questionDTO.getCategory()));
        }
        question.setCreatedAt(LocalDateTime.now());
        Question saveQuestion = questionRepository.save(question);
        List<QuestionImage> questionImages = new ArrayList<>();
        for (MultipartFile image : questionDTO.getImageQuestionUrl()) {
            String imageName = fileUploadAvata.storeImage(subFolder, image);
            String exactImageUrl = urlImage + File.separator + imageName;
            QuestionImage questionImage = new QuestionImage();
            questionImage.setImageUrl(exactImageUrl.replace("\\", "/"));
            questionImage.setQuestion(saveQuestion);
            questionImages.add(questionImage);
        }
        question.setQuestionImage(questionImages);
        questionImageRepository.saveAll(questionImages);
        return saveQuestion;
    }
//    public List<Question> findAll() {
//        return questionRepository.findAll();
//    }
public List<QuestionResponseDTO> findAllQuestions() {
    List<Question> questions = questionRepository.findAll();
    return questions.stream()
            .map(QuestionResponseDTO::new)
            .toList();
}

    public Optional<Question> findById(Long id) {
        return questionRepository.findById(id);
    }

//    public Question updateQuestion(Long id, QuestionDTO questionDTO) {
//        Question questionById = questionRepository.findById(id).orElse(null);
//        questionById.setTitle(questionDTO.getTitle());
//        questionById.setContent(questionDTO.getContent());
//        questionById.setAuthor(questionDTO.getAuthor());
//        questionById.setUpdatedAt(LocalDateTime.now());
//        return questionRepository.save(questionById);
//    }
//
//    private List<QuestionImage> saveImagesForQuestion(MultipartFile[] images) throws IOException {
//        return Arrays.stream(images)
//                .map(image -> {
//                    try {
//                        String storedFileName = fileUploadAvata.storeImage(subFolder, image);
//                        QuestionImage questionImage = new QuestionImage();
//                        questionImage.setImageUrl(GlobalConstant.rootUrl + GlobalConstant.uploadFolder
//                                + "/" + subFolder + "/" + storedFileName);
//                        return questionImage;
//                    } catch (IOException e) {
//                        throw new RuntimeException("Failed to store image", e);
//                    }
//                })
//                .collect(Collectors.toList());
//    }

    public void deleteQuestion(Long id) {
        Optional<Question> questionById = questionRepository.findById(id);
        List<QuestionImage> imagesDelete = questionById.get().getQuestionImage();
        if (imagesDelete.size()>0) {
            for (QuestionImage image : imagesDelete) {
                fileUploadAvata.deleteImage(image.getImageUrl().substring(GlobalConstant.rootUrl.length()));
                questionImageRepository.delete(image);
            }
        }
        questionRepository.deleteById(id);
    }


}
