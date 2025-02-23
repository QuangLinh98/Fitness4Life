package fpt.aptech.bookingservice.service;


import fpt.aptech.bookingservice.dtos.WorkoutPackageDTO;
import fpt.aptech.bookingservice.models.WorkoutPackage;
import fpt.aptech.bookingservice.repository.WorkoutPackageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class WorkoutPackageService {
    private final WorkoutPackageRepository workoutPackageRepository;

    //Handle get all data
    public List<WorkoutPackage> getAllData() {
        return workoutPackageRepository.findAll();
    }

    //Handle get a package
    public WorkoutPackageDTO getWorkoutPackageById(int id) {
        return workoutPackageRepository.findById(id)
                .map(existingPackage -> {
                    WorkoutPackageDTO dto = new WorkoutPackageDTO();
                    dto.setId(existingPackage.getId());
                    dto.setPackageName(existingPackage.getPackageName().toString());
                    dto.setPrice(existingPackage.getPrice());
                    return dto;
                })
                .orElseThrow(() -> new RuntimeException("Workout Package not found"));
    }

    //Handle get many package
    public List<WorkoutPackageDTO> getWorkoutPackagesByIds(List<Integer> ids) {
        List<WorkoutPackage> workoutPackages = workoutPackageRepository.findAllById(ids);
        List<WorkoutPackageDTO> workoutPackageDTOS = new ArrayList<>();
        for (WorkoutPackage workoutPackage : workoutPackages) {
            WorkoutPackageDTO workoutPackageDTO = new WorkoutPackageDTO();
            workoutPackageDTO.setId(workoutPackage.getId());
            workoutPackageDTO.setPackageName(String.valueOf(workoutPackage.getPackageName()));
            workoutPackageDTOS.add(workoutPackageDTO);
        }
        return workoutPackageDTOS;
    }

    //Handle create a package
    public WorkoutPackage addWorkoutPackage(WorkoutPackage workoutPackage) {
        workoutPackage.setCreateAt(LocalDateTime.now());
        return workoutPackageRepository.save(workoutPackage);
    }

    //Handle update package
    public WorkoutPackage updateWorkoutPackage(int id ,WorkoutPackage workoutPackage) {
        WorkoutPackage oldWorkoutPackage = workoutPackageRepository.findById(id).orElseThrow(() -> new RuntimeException("WorkoutPackageNotFound"));
        oldWorkoutPackage.setPackageName(workoutPackage.getPackageName());
        oldWorkoutPackage.setDescription(workoutPackage.getDescription());
        oldWorkoutPackage.setDurationMonth(workoutPackage.getDurationMonth());
        oldWorkoutPackage.setPrice(workoutPackage.getPrice());
        oldWorkoutPackage.setUpdateAt(LocalDateTime.now());
        return workoutPackageRepository.save(oldWorkoutPackage);
    }

    //Handle delete package
    public WorkoutPackage deleteWorkoutPackage(int id) {
        WorkoutPackage workoutPackage = workoutPackageRepository.findById(id).orElseThrow(() -> new RuntimeException("WorkoutPackageNotFound"));
         workoutPackageRepository.delete(workoutPackage);
         return workoutPackage;
    }
}
