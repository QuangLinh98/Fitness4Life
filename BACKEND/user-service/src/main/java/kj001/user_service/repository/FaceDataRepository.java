package kj001.user_service.repository;

import jakarta.transaction.Transactional;
import kj001.user_service.models.FaceData;
import kj001.user_service.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface FaceDataRepository extends JpaRepository<FaceData, Long> {
    Optional<FaceData> findByUser(User user);
    Optional<FaceData> findByUserId(Long userId);
    boolean existsByUser(User user);

    // Custom query để lấy face encodings cho so sánh
    @Query("SELECT f.faceEncoding FROM FaceData f WHERE f.user.isActive = true")
    List<String> findAllActiveFaceEncodings();

    // Query để xóa face data khi user bị xóa
    @Modifying
    @Transactional
    @Query("DELETE FROM FaceData f WHERE f.user.id = :userId")
    void deleteByUserId(Long userId);
}
