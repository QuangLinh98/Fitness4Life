package fpt.aptech.dashboardservice.service;

import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import fpt.aptech.dashboardservice.service.SlugUtil.Slug;
import fpt.aptech.dashboardservice.dtos.ClubDTO;
import fpt.aptech.dashboardservice.dtos.ClubImageDTO;
import fpt.aptech.dashboardservice.dtos.ClubPrimaryImageDTO;
import fpt.aptech.dashboardservice.helpers.FileUpload;
import fpt.aptech.dashboardservice.models.Club;
import fpt.aptech.dashboardservice.models.ClubImages;
import fpt.aptech.dashboardservice.repository.ClubImageRepository;
import fpt.aptech.dashboardservice.repository.ClubRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ClubService {
    private final ClubRepository clubRepository;
    private final ClubImageRepository clubImageRepository;
    private final ObjectMapper objectMapper;
    private final FileUpload fileUpload;
    private String subFolder = "ClubImage";
    String upFolder = "uploads";
    private String rootUrl = "http://localhost:8080/";
    private String urlImage = rootUrl + upFolder + File.separator + subFolder;

    //Handle get all data
    public List<Club> getAllClubs() {
        return clubRepository.findAll();
    }

    //Handle get one Club
    public Club getClubById(int id) {
        return clubRepository.findById(id).get();
    }

    //Check contactPhone has exist
    private boolean existByContactPhone(String contactPhone) {
        return clubRepository.existsByContactPhone(contactPhone);
    }

    //Handle add Club
    public Club addClub(ClubDTO clubDTO) {
        //Check contactPhone unique
        if (existByContactPhone(clubDTO.getContactPhone())) {
            throw new RuntimeException("ContactPhoneAlreadyExists");
        }

        clubDTO.setCreateAt(LocalDateTime.now());
        Club club = objectMapper.convertValue(clubDTO, Club.class);
        club = clubRepository.save(club);
        //Lưu data vào db để có did trước khi tạo slug
        String slug = Slug.generateSlug(club.getName(), club.getId());
        club.setSlug(slug);
        return clubRepository.save(club);
    }


    //Handle update a club
    public Club updateClub(int id, ClubDTO clubDTO) throws JsonMappingException {
        Optional<Club> clubExisting = clubRepository.findById(id);

        //Kiểm tra club có tồn tại hay không
        if (clubExisting.isPresent()) {
            Club clubUpdate = clubExisting.get();
            clubUpdate.setName(clubDTO.getName());
            clubUpdate.setAddress(clubDTO.getAddress());
            clubUpdate.setContactPhone(clubDTO.getContactPhone());
            clubUpdate.setDescription(clubDTO.getDescription());
            clubUpdate.setOpenHour(clubDTO.getOpenHour());
            clubUpdate.setCloseHour(clubDTO.getCloseHour());
            clubUpdate.setUpdateAt(LocalDateTime.now());

            //update lại slug dựa trên club name
            String slug = Slug.generateSlug(clubUpdate.getName(), clubUpdate.getId());
            clubUpdate.setSlug(slug);

            objectMapper.updateValue(clubDTO, Club.class);
            return clubRepository.save(clubUpdate);
        } else {
            throw new RuntimeException("ClubNotFound");
        }
    }

    //Handle delete a club
    public void deleteClubById(int id) {
        Optional<Club> clubExisting = clubRepository.findById(id);
        if (clubExisting.isPresent()) {
            clubRepository.deleteById(id);
        } else {
            throw new RuntimeException("ClubNotFound");
        }
    }

    //handle add club image
    public ClubImages addClubImages(ClubImageDTO clubImageDTO) throws IOException {
        if (clubImageDTO.isPrimary()) {
            boolean hasPrimaryImage = clubImageRepository
                    .existByClubIdAndIsPrimary(clubImageDTO.getClubId(), true);
            if (hasPrimaryImage) {
                throw new RuntimeException("PrimaryImageAlreadyExists");
            }
        }
        //Tạo image name
        String imageName = fileUpload.storeImage(subFolder, clubImageDTO.getFile());
        //Tạo đường dẫn chính xác
        String exacImagePath = urlImage + File.separator + imageName;

        //Tìm Club theo id
        Optional<Club> clubExisting = clubRepository.findById(clubImageDTO.getClubId());
        ClubImages clubImages = ClubImages.builder()
                .createdAt(LocalDateTime.now())
                .imageUrl(exacImagePath.replace("\\", "/"))
                .isPrimary(clubImageDTO.isPrimary())
                .build();
        clubImages.setClub(clubExisting.get());
        return clubImageRepository.save(clubImages);
    }

    //Handle find club image by id
    public Optional<ClubImages> findClubImageById(int id) {
        return clubImageRepository.findById(id);
    }

    //Handle update image of Club
    @Transactional
    public ClubImages updateClubImage(int imageId, ClubImageDTO clubImageDTO) throws IOException {
        if (clubImageDTO.isPrimary()) {
            boolean hasPrimaryImage = clubImageRepository
                    .existByClubIdAndIsPrimary(clubImageDTO.getClubId(), true);
            if (hasPrimaryImage) {
                throw new RuntimeException("PrimaryImageAlreadyExists");
            }
        }

        Optional<ClubImages> imageExisting = findClubImageById(imageId);
        String clubImageUrl = imageExisting.get().getImageUrl();
        if (clubImageDTO.getFile() != null && clubImageDTO.getFile().getSize() > 0) {
            //Tạo image name
            String imageName = fileUpload.storeImage(subFolder, clubImageDTO.getFile());
            //Tạo đường dẫn chính xác
            String exacImagePath = urlImage + File.separator + imageName;
            if (clubImageUrl != null) {
                fileUpload.deleteImage(clubImageUrl.substring(rootUrl.length()));
            }
            clubImageUrl = exacImagePath.replace("\\", "/");
        }
        Optional<Club> club = clubRepository.findById(clubImageDTO.getClubId());
        ClubImages clubImages = ClubImages.builder()
                .id(imageId)
                .createdAt(LocalDateTime.now())
                .updateAt(LocalDateTime.now())
                .imageUrl(clubImageUrl)
                .isPrimary(clubImageDTO.isPrimary())
                .build();
        clubImages.setClub(club.get());
        return clubImageRepository.save(clubImages);
    }

    //Handle get all club with primary image
    public List<ClubPrimaryImageDTO> getAllClubWithPrimaryImage() {
        List<Club> clubs = clubRepository.findAll();
        List<ClubPrimaryImageDTO> clubImageDTOs = new ArrayList<>();
        //Duyệt qua từng Club
        for (Club club : clubs) {
            //lấy danh sach tất cả hình ảnh liên quan đến Club
            List<ClubImages> images = clubImageRepository.findByClub(club);
            //Lọc ra hình ảnh chính
            ClubImages primaryImage = images.stream()
                    .filter(ClubImages::isPrimary)  //Sử dụng method reference đê lọc
                    .findFirst()  //Lấy ra hình ảnh chính đầu tiên
                    .orElse(null);   //Không có trả về null

            //Thiết lập hình ảnh chính vào Club
            //Tạo DTO và thêm vào danh sách kêt quả bằng cách sw dụng builder
            ClubPrimaryImageDTO clubPrimaryImageDTO = ClubPrimaryImageDTO.builder()
                    .id(club.getId())
                    .name(club.getName())
                    .address(club.getAddress())
                    .contactPhone(club.getContactPhone())
                    .description(club.getDescription())
                    .openHour(club.getOpenHour())
                    .closeHour(club.getCloseHour())
                    .createAt(club.getCreateAt())
                    .primaryImage(primaryImage)
                    .build();

            clubImageDTOs.add(clubPrimaryImageDTO);
        }
        return clubImageDTOs;
    }

    //Handle delete image of club by id
    public ClubImages deleteClubImageById(int id) {
        Optional<ClubImages> imageExisting = clubImageRepository.findById(id);
        if (imageExisting.get().getImageUrl() != null) {
            fileUpload.deleteImage(imageExisting.get().getImageUrl().substring(rootUrl.length()));
        }
        clubImageRepository.deleteById(id);
        return imageExisting.get();
    }

    //Handle set primary image for club
    public void activePrimaryClubImageById(int id, int clubId) {
        clubImageRepository.updateOtherClubImagesPrimary(id, clubId);
    }

}
