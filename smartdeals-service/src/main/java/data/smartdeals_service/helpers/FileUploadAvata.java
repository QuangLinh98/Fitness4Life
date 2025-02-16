package data.smartdeals_service.helpers;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Service
public class FileUploadAvata {
    @Value("${upload.folder}")
    private String uploadFolder;

    // hàm MIME types hợp lệ (check các định dạng file hợp lệ)
    private static final String[] ALLOWED_MIME_TYPES = {
            "image/png", "image/jpeg","image/gif","image/bmp",
            "image/webp","image/tiff", "image/x-icon","image/svg+xml",
            "video/mp4","video/x-msvideo", "video/x-matroska",
            "video/quicktime", "video/x-ms-wmv", "video/x-flv",
            "video/webm", "video/3gpp", "video/mpeg"
    };

    public String storeImage(String subFolder, MultipartFile multipartFile) throws IOException {

        // Kiểm tra loại file (MIME type)
        String fileType = multipartFile.getContentType();
        boolean isValidType = false;
        for (String mimeType : ALLOWED_MIME_TYPES) {
            if (mimeType.equals(fileType)) {
                isValidType = true;
                break;
            }
        }

        // lỗi xuất dưới terminal và status 500 server error
        if (!isValidType) {
            throw new IllegalArgumentException("Loại file không được hỗ trợ. Chỉ chấp nhận các loại: image/png, image/jpeg.");
        }

        // tạo thư mục nếu chưa tồn tại
        String exactFolderPath = uploadFolder + File.separator + subFolder;
        File directory = new File(exactFolderPath);
        if (!directory.exists()) {
            directory.mkdirs();
        }
//        // tạo tên đường dẫn
//        String fileName = UUID.randomUUID().toString()+"_"+ multipartFile.getOriginalFilename();

        // Tạo tên file mới không chứa khoảng trắng
        String originalFileName = multipartFile.getOriginalFilename();
        String sanitizedFileName = originalFileName != null ? originalFileName.replaceAll("\\s+", "_") : "default_file";
        String fileName = UUID.randomUUID().toString() + "_" + sanitizedFileName;
        Path destination = Path.of(exactFolderPath, fileName);


        // lưu file
        Files.copy(multipartFile.getInputStream(), destination);

        return fileName;
    }

    public void deleteImage(String imageExisted) {
        try {
            Path imageDelete = Paths.get(imageExisted);
            if (Files.exists(imageDelete)) {
                Files.delete(imageDelete);
                System.out.println("Successfully deleted file: " + imageExisted);
            } else {
                System.err.println("File not found: " + imageExisted);
            }
        } catch (IOException e) {
            System.err.println("Error deleting file: " + imageExisted);
            e.printStackTrace();
        }
    }



}
