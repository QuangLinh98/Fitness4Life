package fpt.aptech.dashboardservice.repository;

import fpt.aptech.dashboardservice.models.Club;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClubRepository extends JpaRepository<Club, Integer> {
    //Kiểm tra phone đã tồn tại hay chưa
     boolean existsByContactPhone(String contactPhone);
}
