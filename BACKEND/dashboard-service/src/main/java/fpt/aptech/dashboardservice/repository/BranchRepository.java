package fpt.aptech.dashboardservice.repository;

import fpt.aptech.dashboardservice.models.Branch;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BranchRepository extends JpaRepository<Branch, Integer> {
}
