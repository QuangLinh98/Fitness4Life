package data.smartdeals_service.services.forumServices;

import data.smartdeals_service.dto.forum.QuestionDTO;
import data.smartdeals_service.dto.forum.QuestionResponseDTO;
import data.smartdeals_service.helpers.FileUploadAvata;
import data.smartdeals_service.helpers.GlobalConstant;
import data.smartdeals_service.models.forum.*;
import data.smartdeals_service.repository.forumRepositories.QuestionImageRepository;
import data.smartdeals_service.repository.forumRepositories.QuestionRepository;
import data.smartdeals_service.repository.forumRepositories.QuestionViewRepository;
import data.smartdeals_service.repository.forumRepositories.QuestionVoteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;


@Service
@RequiredArgsConstructor
public class QuestionService {
    private final QuestionRepository questionRepository;
    private final QuestionImageRepository questionImageRepository;
    private final QuestionVoteRepository questionVoteRepository;
    private final QuestionViewRepository questionViewRepository;
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
        question.setRolePost(questionDTO.getRolePost());

        if (questionDTO.getCategory() != null) {
            List<CategoryForum> categories = questionDTO.getCategory().stream()
                    .map(CategoryForum::valueOf)
                    .toList();
            question.setCategory(categories);
        }
        question.setCreatedAt(LocalDateTime.now());
        Question savedQuestion = questionRepository.save(question);

        // Lưu hình ảnh
        if (questionDTO.getImageQuestionUrl() != null && !questionDTO.getImageQuestionUrl().isEmpty()) {
            List<QuestionImage> questionImages = new ArrayList<>();
            for (MultipartFile image : questionDTO.getImageQuestionUrl()) {
                if (image != null && !image.isEmpty()) { // Kiểm tra file không null hoặc trống
                    String imageName = fileUploadAvata.storeImage(subFolder, image);
                    String exactImageUrl = urlImage + File.separator + imageName;
                    QuestionImage questionImage = new QuestionImage();
                    questionImage.setImageUrl(exactImageUrl.replace("\\", "/"));
                    questionImage.setQuestion(savedQuestion);
                    questionImages.add(questionImage);
                }
            }
            if (!questionImages.isEmpty()) {
                questionImageRepository.saveAll(questionImages);
                question.setQuestionImage(questionImages);
            }
        }
        return savedQuestion;
    }

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

    @Transactional
    public void handleVote(Long questionId, Long userId, VoteType newVoteType) {
        // Lấy thông tin câu hỏi
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("Question not found"));

        // Kiểm tra user đã vote chưa
        Optional<QuestionVote> existingVote = questionVoteRepository.findByQuestionIdAndUserId(questionId, userId);

        if (existingVote.isPresent()) {
            QuestionVote vote = existingVote.get();

            // Nếu user đã vote cùng loại thì bỏ vote (toggle off)
            if (vote.getVoteType() == newVoteType) {
                questionVoteRepository.delete(vote);
                if (newVoteType == VoteType.UPVOTE) {
                    question.setUpvote(question.getUpvote() - 1);
                } else if (newVoteType == VoteType.DOWNVOTE) {
                    question.setDownVote(question.getDownVote() - 1);
                }
            } else {
                // Nếu user đã vote khác loại thì chuyển đổi
                if (vote.getVoteType() == VoteType.UPVOTE) {
                    question.setUpvote(question.getUpvote() - 1);
                    question.setDownVote(question.getDownVote() + 1);
                } else if (vote.getVoteType() == VoteType.DOWNVOTE) {
                    question.setDownVote(question.getDownVote() - 1);
                    question.setUpvote(question.getUpvote() + 1);
                }
                vote.setVoteType(newVoteType);
                questionVoteRepository.save(vote);
            }
        } else {
            // Nếu user chưa vote thì tạo vote mới
            QuestionVote newVote = new QuestionVote();
            newVote.setQuestion(question);
            newVote.setUserId(userId);
            newVote.setVoteType(newVoteType);
            questionVoteRepository.save(newVote);

            if (newVoteType == VoteType.UPVOTE) {
                question.setUpvote(question.getUpvote() + 1);
            } else if (newVoteType == VoteType.DOWNVOTE) {
                question.setDownVote(question.getDownVote() + 1);
            }
        }

        // Cập nhật lại question trong database
        questionRepository.save(question);
    }

    public void incrementViewCount(Long questionId, Long userId) {
        Optional<QuestionView> existingView = questionViewRepository.findByQuestionIdAndUserId(questionId, userId);

        if (existingView.isEmpty()) {
            // User chưa xem bài viết, tăng viewCount
            Question question = questionRepository.findById(questionId)
                    .orElseThrow(() -> new RuntimeException("Question not found"));
            question.setViewCount(question.getViewCount() + 1);

            // Lưu lại thông tin lượt xem
            QuestionView questionView = new QuestionView();
            questionView.setQuestion(question);
            questionView.setUserId(userId);

            questionViewRepository.save(questionView);
            questionRepository.save(question);
        }
        // Nếu đã xem, không làm gì thêm
    }

}
