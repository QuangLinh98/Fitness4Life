package fpt.aptech.bookingservice.dtos;

import fpt.aptech.bookingservice.models.PackageName;
import lombok.Data;

@Data
public class WorkoutPackageDTO {
    private int Id;
    private String packageName;
    private double price;
}
