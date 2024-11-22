package fpt.aptech.dashboardservice.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import fpt.aptech.dashboardservice.dtos.BranchDTO;
import fpt.aptech.dashboardservice.models.Branch;
import fpt.aptech.dashboardservice.models.ServiceBranch;
import fpt.aptech.dashboardservice.repository.BranchRepository;
import fpt.aptech.dashboardservice.service.SlugUtil.Slug;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class BranchService {
    private final BranchRepository branchRepository;
    private final ObjectMapper objectMapper;

    //Handle get all data
    public List<Branch> getAllBranch() {
        return branchRepository.findAll();
    }

    //Handle get one Branch by id
    public Branch getBranchById(int id) {
        return branchRepository.findById(id).get();
    }

    //Handle add a new Branch
    public Branch createBranch(BranchDTO branchDTO) {
        branchDTO.setCreateAt(LocalDateTime.now());
        Branch newBranch = objectMapper.convertValue(branchDTO, Branch.class);
        newBranch = branchRepository.save(newBranch);
        String slug = Slug.generateSlug(newBranch.getBranchName(), newBranch.getId());
        newBranch.setSlug(slug);
        return branchRepository.save(newBranch);
    }

    //Handle update an Branch
    public Branch updateBranch(int id, BranchDTO branchDTO) {
        Optional<Branch> branchExisting = branchRepository.findById(id);

        Branch branchUpdate = branchExisting.get();
        branchUpdate.setBranchName(branchDTO.getBranchName());
        branchUpdate.setAddress(branchDTO.getAddress());
        branchUpdate.setPhoneNumber(branchDTO.getPhoneNumber());
        branchUpdate.setEmail(branchDTO.getEmail());
        branchUpdate.setOpenHours(branchDTO.getOpenHours());
        branchUpdate.setCloseHours(branchDTO.getCloseHours());
        branchUpdate.setServices(branchDTO.getServices());
        branchUpdate.setUpdateAt(LocalDateTime.now());

        String slug = Slug.generateSlug(branchUpdate.getBranchName(), branchUpdate.getId());
        branchUpdate.setSlug(slug);

        objectMapper.convertValue(branchUpdate, Branch.class);
        return branchRepository.save(branchUpdate);
    }

    //Handle delete an Branch
    public void deleteBranch(int id) {
        branchRepository.deleteById(id);
    }
}
