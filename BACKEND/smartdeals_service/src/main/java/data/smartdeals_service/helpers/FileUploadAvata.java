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

    public String storeImage(String subFolder, MultipartFile multipartFile) throws IOException {
        String exactFolderPath = uploadFolder + File.separator + subFolder;
        File directory = new File(exactFolderPath);
        if (!directory.exists()) {
            directory.mkdirs();
        }
        String fileName = UUID.randomUUID().toString() +"_"+ multipartFile.getOriginalFilename();
        Path destination = Path.of(exactFolderPath, fileName);
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
