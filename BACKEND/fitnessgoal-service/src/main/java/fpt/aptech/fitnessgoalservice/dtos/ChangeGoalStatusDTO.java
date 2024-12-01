package fpt.aptech.fitnessgoalservice.dtos;

import fpt.aptech.fitnessgoalservice.models.GoalStatus;
import lombok.Data;

@Data
public class ChangeGoalStatusDTO {
    private String goalStatus;
}
