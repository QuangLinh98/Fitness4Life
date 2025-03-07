package kj001.user_service.service;
import jakarta.annotation.PostConstruct;
import kj001.user_service.dtos.FaceDataReponse;
import kj001.user_service.models.*;
import kj001.user_service.repository.FaceDataRepository;
import kj001.user_service.repository.TokenRepository;
import kj001.user_service.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.util.unit.DataSize;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class FaceAuthService {
    private final UserRepository userRepository;
    private final FaceDataRepository faceDataRepository;
    private final TokenRepository tokenRepository;
    private final JwtService jwtService;
    private final RestTemplate restTemplate;

    private Path absoluteUploadDir;

    @Value("${app.face-recognition.upload-dir}")
    private String uploadDirConfig;

    @Value("${app.face-recognition.allowed-types}")
    private List<String> allowedTypes;

    @Value("${app.face-recognition.max-file-size:5MB}")
    private DataSize maxFileSize;

    @Value("${app.face-recognition.python-service-url}")
    private String pythonServiceUrl;

    @Value("${app.face-recognition.min-face-size:160}")
    private int minFaceSize;

    @Value("${app.face-recognition.matching-threshold:0.5}")
    private double matchingThreshold;

    @Value("${server.port:8080}")
    private String serverPort;

    @Autowired
    public FaceAuthService(
            UserRepository userRepository,
            FaceDataRepository faceDataRepository,
            TokenRepository tokenRepository,
            JwtService jwtService) {
        this.userRepository = userRepository;
        this.faceDataRepository = faceDataRepository;
        this.tokenRepository = tokenRepository;
        this.jwtService = jwtService;
        this.restTemplate = new RestTemplate();
    }

    @PostConstruct
    public void init() {
        try {
            // Normalize path and make it absolute
            File rawDir = new File(uploadDirConfig);

            // Force absolute path
            if (!rawDir.isAbsolute()) {
                // Create absolute path based on current directory
                rawDir = new File(System.getProperty("user.dir"), uploadDirConfig);
            }

            // Remove any "./" or "../" notations by getting canonical path
            absoluteUploadDir = rawDir.getCanonicalFile().toPath();

            // Make sure directory exists
            Files.createDirectories(absoluteUploadDir);

            System.out.println("Face upload directory (normalized): " + absoluteUploadDir);
        } catch (Exception e) {
            System.err.println("Error initializing upload directory: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void validateImage(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("No file provided");
        }

        if (!allowedTypes.contains(file.getContentType())) {
            throw new RuntimeException("Invalid file type. Allowed types: " + String.join(", ", allowedTypes));
        }

        if (file.getSize() > maxFileSize.toBytes()) {
            throw new RuntimeException("File size exceeds maximum limit of " + maxFileSize.toMegabytes() + "MB");
        }
    }

    /**
     * Generates a public-facing URL for the face image
     */
    private String generatePublicUrl(String fileName) {
        return "http://localhost:" + serverPort + "/uploads/faces/" + fileName;
    }

    public void registerFace(Long userId, MultipartFile faceImage) throws IOException {
        validateImage(faceImage);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Check if user already has face data
        if (faceDataRepository.existsByUser(user)) {
            throw new RuntimeException("Face data already exists for this user");
        }

        // Lấy encoding của khuôn mặt mới
        String newFaceEncoding = getFaceEncodingFromPythonService(faceImage);

        // Kiểm tra so sánh với tất cả các khuôn mặt đã đăng ký
        List<FaceData> allFaces = faceDataRepository.findAll();
        for (FaceData existingFace : allFaces) {
            boolean isMatch = compareFacesWithPythonService(
                    existingFace.getFaceEncoding(),
                    newFaceEncoding
            );

            if (isMatch) {
                throw new RuntimeException("This face is already registered to another user");
            }
        }

        // Save image file with original file extension
        String originalFilename = faceImage.getOriginalFilename();
        String fileExtension = originalFilename != null && originalFilename.contains(".")
                ? originalFilename.substring(originalFilename.lastIndexOf("."))
                : ".jpg";

        String fileName = UUID.randomUUID().toString() + fileExtension;
        String publicUrl = generatePublicUrl(fileName);

        // Use the absolute path created during initialization
        Path destinationPath = absoluteUploadDir.resolve(fileName);

        // Double-check directory exists (in case it was deleted after initialization)
        Files.createDirectories(absoluteUploadDir);

        System.out.println("Saving face image to: " + destinationPath);

        // Transfer the file using NIO
        Files.copy(faceImage.getInputStream(), destinationPath);

        try {
            // Get face encoding from Python service
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("file", new FileSystemResource(destinationPath));
            body.add("min_face_size", minFaceSize);

            HttpEntity<MultiValueMap<String, Object>> requestEntity =
                    new HttpEntity<>(body, headers);

            ResponseEntity<String> response = restTemplate.postForEntity(
                    pythonServiceUrl + "/encode-face",
                    requestEntity,
                    String.class
            );

            if (response.getStatusCode() != HttpStatus.OK) {
                throw new RuntimeException("Failed to encode face");
            }

            // Check one more time to prevent race condition
            if (faceDataRepository.existsByUser(user)) {
                Files.deleteIfExists(destinationPath); // Clean up file
                throw new RuntimeException("Face data already exists for this user");
            }

            // Save face data
            FaceData faceData = new FaceData();
            faceData.setUser(user);
            faceData.setFaceEncoding(response.getBody());
            faceData.setOriginalImagePath(publicUrl);  // Store the public URL directly

            faceDataRepository.save(faceData);

        } catch (Exception e) {
            // Clean up file if encoding fails
            Files.deleteIfExists(destinationPath);
            throw e;
        }
    }
    private String getFaceEncodingFromPythonService(MultipartFile faceImage) throws IOException {
        // Chuyển đổi MultipartFile thành File và gọi API encode-face
        Path tempPath = saveTemporaryFile(faceImage);
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("file", new FileSystemResource(tempPath));

            HttpEntity<MultiValueMap<String, Object>> requestEntity =
                    new HttpEntity<>(body, headers);

            ResponseEntity<String> response = restTemplate.postForEntity(
                    pythonServiceUrl + "/encode-face",
                    requestEntity,
                    String.class
            );

            if (response.getStatusCode() != HttpStatus.OK) {
                throw new RuntimeException("Failed to encode face");
            }

            return response.getBody();
        } finally {
            Files.deleteIfExists(tempPath);
        }
    }
    private Path saveTemporaryFile(MultipartFile faceImage) throws IOException {
        // Kiểm tra ảnh
        validateImage(faceImage);

        // Tạo tên file tạm thời duy nhất
        String originalFilename = faceImage.getOriginalFilename();
        String fileExtension = originalFilename != null && originalFilename.contains(".")
                ? originalFilename.substring(originalFilename.lastIndexOf("."))
                : ".jpg";

        String tempFileName = "temp_" + UUID.randomUUID().toString() + fileExtension;

        // Sử dụng đường dẫn upload đã được chuẩn bị sẵn
        Path tempPath = absoluteUploadDir.resolve(tempFileName);

        // Đảm bảo thư mục tồn tại
        Files.createDirectories(absoluteUploadDir);

        // Ghi file tạm
        try (InputStream inputStream = faceImage.getInputStream()) {
            Files.copy(inputStream, tempPath, StandardCopyOption.REPLACE_EXISTING);
        }

        return tempPath;
    }

    private boolean compareFacesWithPythonService(String knownEncoding, String unknownEncoding) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> body = new HashMap<>();
        body.put("known_encoding", knownEncoding);
        body.put("unknown_encoding", unknownEncoding);
        body.put("threshold", matchingThreshold);  // Sử dụng ngưỡng từ cấu hình

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);

        ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                pythonServiceUrl + "/compare-faces",
                HttpMethod.POST,
                request,
                new ParameterizedTypeReference<Map<String, Object>>() {}
        );

        return Boolean.TRUE.equals(response.getBody().get("match"));
    }

    public AuthenticationResponse loginWithFace(MultipartFile faceImage) throws IOException {
        validateImage(faceImage);

        // Save temp image
        String originalFilename = faceImage.getOriginalFilename();
        String fileExtension = originalFilename != null && originalFilename.contains(".")
                ? originalFilename.substring(originalFilename.lastIndexOf("."))
                : ".jpg";

        String tempFileName = "temp_" + UUID.randomUUID().toString() + fileExtension;

        // Use the absolute path created during initialization
        Path tempPath = absoluteUploadDir.resolve(tempFileName);

        // Double-check directory exists
        Files.createDirectories(absoluteUploadDir);

        System.out.println("Saving temp face image to: " + tempPath);

        // Transfer the file using NIO
        Files.copy(faceImage.getInputStream(), tempPath);

        try {
            // Get face encoding from Python service
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("file", new FileSystemResource(tempPath));
            body.add("min_face_size", minFaceSize);

            HttpEntity<MultiValueMap<String, Object>> requestEntity =
                    new HttpEntity<>(body, headers);

            ResponseEntity<String> response = restTemplate.postForEntity(
                    pythonServiceUrl + "/encode-face",
                    requestEntity,
                    String.class
            );

            if (response.getStatusCode() != HttpStatus.OK) {
                throw new RuntimeException("Failed to encode face");
            }

            String faceEncoding = response.getBody();

            // Find matching face in database
            List<FaceData> allFaces = faceDataRepository.findAll();
            User matchedUser = null;

            for (FaceData faceData : allFaces) {
                HttpHeaders compareHeaders = new HttpHeaders();
                compareHeaders.setContentType(MediaType.APPLICATION_JSON);

                Map<String, Object> compareBody = new HashMap<>();
                compareBody.put("known_encoding", faceData.getFaceEncoding());
                compareBody.put("unknown_encoding", faceEncoding);
                compareBody.put("threshold", matchingThreshold);

                HttpEntity<Map<String, Object>> compareRequest =
                        new HttpEntity<>(compareBody, compareHeaders);

                ResponseEntity<Map<String, Object>> compareResponse = restTemplate.exchange(
                        pythonServiceUrl + "/compare-faces",
                        HttpMethod.POST,
                        compareRequest,
                        new ParameterizedTypeReference<Map<String, Object>>() {}
                );

                if (compareResponse.getBody() != null &&
                        Boolean.TRUE.equals(compareResponse.getBody().get("match"))) {
                    matchedUser = faceData.getUser();
                    break;
                }
            }
            if (matchedUser == null) {
                throw new RuntimeException("No matching face found");
            }

            // Generate tokens
            String accessToken = jwtService.generateAccessToken(matchedUser);
            String refreshToken = jwtService.generateRefreshToken(matchedUser);

            // Revoke old tokens
            tokenRepository.findAllAccessTokensByUser(matchedUser.getId())
                    .forEach(t -> {
                        t.setLoggedOut(true);
                        tokenRepository.save(t);
                    });

            // Save new token
            Token token = new Token();
            token.setUser(matchedUser);
            token.setAccessToken(accessToken);
            token.setRefreshToken(refreshToken);
            token.setLoggedOut(false);
            tokenRepository.save(token);

            return new AuthenticationResponse(accessToken, refreshToken, "Face login successful");

        } finally {
            // Clean up temp file
            Files.deleteIfExists(tempPath);
        }
    }

    public void updateFace(Long userId, MultipartFile newFaceImage) throws IOException {
        validateImage(newFaceImage);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Check if user has face data
        FaceData existingFaceData = faceDataRepository.findByUser(user)
                .orElseThrow(() -> new RuntimeException("No face data exists for this user"));

        // Get encoding of the new face
        String newFaceEncoding = getFaceEncodingFromPythonService(newFaceImage);

        // Check for matches with other users (excluding current user)
        List<FaceData> allOtherFaces = faceDataRepository.findAll().stream()
                .filter(face -> !Long.valueOf(face.getUser().getId()).equals(userId))
                .toList();

        for (FaceData otherFace : allOtherFaces) {
            boolean isMatch = compareFacesWithPythonService(
                    otherFace.getFaceEncoding(),
                    newFaceEncoding
            );

            if (isMatch) {
                throw new RuntimeException("This face is already registered to another user");
            }
        }

        // Save new image file with original file extension
        String originalFilename = newFaceImage.getOriginalFilename();
        String fileExtension = originalFilename != null && originalFilename.contains(".")
                ? originalFilename.substring(originalFilename.lastIndexOf("."))
                : ".jpg";

        String fileName = UUID.randomUUID().toString() + fileExtension;
        String publicUrl = generatePublicUrl(fileName);

        // Use the absolute path created during initialization
        Path destinationPath = absoluteUploadDir.resolve(fileName);

        // Double-check directory exists (in case it was deleted after initialization)
        Files.createDirectories(absoluteUploadDir);

        System.out.println("Saving new face image to: " + destinationPath);

        // Transfer the file using NIO
        Files.copy(newFaceImage.getInputStream(), destinationPath);

        try {
            // Get face encoding from Python service for the new image
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("file", new FileSystemResource(destinationPath));
            body.add("min_face_size", minFaceSize);

            HttpEntity<MultiValueMap<String, Object>> requestEntity =
                    new HttpEntity<>(body, headers);

            ResponseEntity<String> response = restTemplate.postForEntity(
                    pythonServiceUrl + "/encode-face",
                    requestEntity,
                    String.class
            );

            if (response.getStatusCode() != HttpStatus.OK) {
                throw new RuntimeException("Failed to encode face");
            }

            // Extract old image path to delete later
            String oldImagePath = existingFaceData.getOriginalImagePath();
            String oldFileName = null;
            if (oldImagePath != null && oldImagePath.contains("/")) {
                oldFileName = oldImagePath.substring(oldImagePath.lastIndexOf("/") + 1);
            }

            // Update face data
            existingFaceData.setFaceEncoding(response.getBody());
            existingFaceData.setOriginalImagePath(publicUrl);
            faceDataRepository.save(existingFaceData);

            // Delete old image file
            if (oldFileName != null) {
                Path oldImageFilePath = absoluteUploadDir.resolve(oldFileName);
                Files.deleteIfExists(oldImageFilePath);
                System.out.println("Deleted old face image: " + oldImageFilePath);
            }

        } catch (Exception e) {
            // Clean up new file if encoding or saving fails
            Files.deleteIfExists(destinationPath);
            throw e;
        }
    }
    public List<FaceDataReponse> getAllFaceData() {
        List<FaceData> allFaceData = faceDataRepository.findAll();

        return allFaceData.stream()
                .map(faceData -> {
                    FaceDataReponse response = new FaceDataReponse();
                    response.setFaceId(faceData.getId());
                    response.setUserId(faceData.getUser().getId());
                    response.setImageUrl(faceData.getOriginalImagePath());
                    response.setRegisteredAt(faceData.getCreatedAt());

                    // Add user details
                    User user = faceData.getUser();
                    response.setUsername(user.getUsername());
                    response.setEmail(user.getEmail());

                    return response;
                })
                .collect(Collectors.toList());
    }
}