package fpt.aptech.dashboardservice.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import fpt.aptech.dashboardservice.dtos.TrainerDTO;
import fpt.aptech.dashboardservice.helpers.FileUpload;
import fpt.aptech.dashboardservice.models.Branch;
import fpt.aptech.dashboardservice.models.Trainer;
import fpt.aptech.dashboardservice.repository.BranchRepository;
import fpt.aptech.dashboardservice.repository.TrainerRepository;
import fpt.aptech.dashboardservice.service.SlugUtil.Slug;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class TrainerService {
    private final TrainerRepository trainerRepository;
    private final BranchRepository branchRepository;
    private final ObjectMapper objectMapper;   //Là 1 lớp thư viện trong java , nhằm để chuyển đổi dạng Object sang JSON
    private final FileUpload fileUpload;
    private String subFolder = "TrainerImage";
    String uploadFolder = "uploads";
    private String rootUrl = "http://localhost:8081/";
    private String urlImage = rootUrl + uploadFolder + File.separator + subFolder;


    //Handle get all data
    public List<Trainer> getAllTrainer() {
        return trainerRepository.findAll();
    }

    //Handle get a Trainer by id
    public Trainer getTrainerById(int id) {
        return trainerRepository.findById(id).get();
    }

    //Handle create a new Trainer
    public Trainer createTrainer(TrainerDTO trainerDTO) throws IOException {
        //Tạo image name
        String imageName = fileUpload.storeImage(subFolder, trainerDTO.getFile());
        //Tạo url chính xác cho image
        String exacImage = urlImage + File.separator + imageName;


        Optional<Branch> branchExisting = branchRepository.findById(trainerDTO.getBranch());
        Trainer trainer = Trainer.builder()
                .fullName(trainerDTO.getFullName())
                .photo(exacImage.replace("\\", "/"))
                .specialization(trainerDTO.getSpecialization())
                .experienceYear(trainerDTO.getExperienceYear())
                .certificate(trainerDTO.getCertificate())
                .phoneNumber(trainerDTO.getPhoneNumber())
                .scheduleTrainers(trainerDTO.getScheduleTrainers())
                .createAt(LocalDateTime.now())
                .build();
        trainer.setBranch(branchExisting.get());
        trainer = trainerRepository.save(trainer);
        String slug = Slug.generateSlug(trainer.getFullName(), trainer.getId());
        trainer.setSlug(slug);
        return trainerRepository.save(trainer);
    }

    //Handle update Trainer
    public Trainer updateTrainer(int id, TrainerDTO trainerDTO) throws IOException {
        Trainer trainerExisting = trainerRepository.findById(id).orElseThrow(() -> new RuntimeException("Trainer not found"));
        String trainerImageUrl = trainerExisting.getPhoto();

        if (trainerDTO.getFile().getSize() > 0) {
            String imageName = fileUpload.storeImage(subFolder, trainerDTO.getFile());
            String exactImagePath = urlImage + File.separator + imageName;
            if (trainerImageUrl != null) {
                fileUpload.deleteImage(trainerImageUrl.substring(rootUrl.length()));
            }
            trainerImageUrl = exactImagePath.replace("\\", "/");
        }
        Branch branchExisting = branchRepository.findById(trainerDTO.getBranch()).get();
        trainerExisting.setFullName(trainerDTO.getFullName());
        trainerExisting.setPhoto(trainerImageUrl);  // Cập nhật ảnh
        trainerExisting.setSpecialization(trainerDTO.getSpecialization());
        trainerExisting.setExperienceYear(trainerDTO.getExperienceYear());
        trainerExisting.setCertificate(trainerDTO.getCertificate());
        trainerExisting.setPhoneNumber(trainerDTO.getPhoneNumber());
        trainerExisting.setScheduleTrainers(trainerDTO.getScheduleTrainers());
        trainerExisting.setUpdateAt(LocalDateTime.now());
        trainerExisting.setBranch(branchExisting);

        String slug = Slug.generateSlug(trainerExisting.getFullName(), trainerExisting.getId());
        trainerExisting.setSlug(slug);

        return trainerRepository.save(trainerExisting);
    }

    //Handle delete a Trainer
    public void deleteTrainer(int id) {
        Optional<Trainer> trainerExisting = trainerRepository.findById(id);
        if (trainerExisting.get().getPhoto() != null) {
            fileUpload.deleteImage(trainerExisting.get().getPhoto().substring(rootUrl.length()));
        }
        trainerRepository.deleteById(id);
    }
}
