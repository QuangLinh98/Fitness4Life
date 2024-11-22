package fpt.aptech.bookingservice.service;


import fpt.aptech.bookingservice.models.WorkoutPackage;
import fpt.aptech.bookingservice.repository.WorkoutPackageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class WorkoutPackageService {
    private final WorkoutPackageRepository workoutPackageRepository;

    //Handle get all data
    public List<WorkoutPackage> getAllData() {
        return workoutPackageRepository.findAll();
    }

    //Handle get a package
    public WorkoutPackage getWorkoutPackageById(int id) {
        return workoutPackageRepository.findById(id).orElseThrow(() -> new RuntimeException("PackageNotFound"));
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
