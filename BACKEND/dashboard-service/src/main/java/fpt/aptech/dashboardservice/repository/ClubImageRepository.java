package fpt.aptech.dashboardservice.repository;

import fpt.aptech.dashboardservice.models.Club;
import fpt.aptech.dashboardservice.models.ClubImages;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ClubImageRepository extends JpaRepository<ClubImages,Integer> {
    // Phương thức tìm tất cả hình ảnh liên quan đến một khách sạn
    List<ClubImages> findByClub(Club club);

    @Query("SELECT COUNT(c) > 0 FROM ClubImages c WHERE c.club.id = :clubId AND c.isPrimary = :isPrimary")
    boolean existByClubIdAndIsPrimary(@Param("clubId") int clubId, @Param("isPrimary") boolean isPrimary);

    //Phương thức update những ảnh khác khi 1 ảnh được thiết lập làm ảnh chính
    @Modifying
    @Transactional
    @Query("UPDATE ClubImages c SET c.isPrimary = CASE WHEN c.id = :id THEN true ELSE false END WHERE c.club.id = :clubId")
    void updateOtherClubImagesPrimary(@Param("id") int id, @Param("clubId") int clubId);
}
