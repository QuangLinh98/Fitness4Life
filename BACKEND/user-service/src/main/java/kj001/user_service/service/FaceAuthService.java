package kj001.user_service.service;
import jakarta.annotation.PostConstruct;
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
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

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
        return "http://localhost:" + serverPort + "/faces/" + fileName;
    }

    public void registerFace(Long userId, MultipartFile faceImage) throws IOException {
        validateImage(faceImage);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Check if user already has face data - validate early
        if (faceDataRepository.existsByUser(user)) {
            throw new RuntimeException("Face data already exists for this user");
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
}