package fpt.aptech.dashboardservice.repository;

import fpt.aptech.dashboardservice.models.WorkoutPackage;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WorkoutPackageRepository extends JpaRepository<WorkoutPackage, Integer> {
}
