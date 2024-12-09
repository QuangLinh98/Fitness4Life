package fpt.aptech.fitnessgoalservice.models;


public enum ActivityLevel {
    SEDENTARY(1.2,"Không vận động hoặc rất ít"),
    LIGHTLY_ACTIVE(1.375, "Hoạt động nhẹ (1-3 ngày/tuần)"),
    MODERATELY_ACTIVE(1.55,"Hoạt động vừa phải (3-5 ngày /tuần"),
    VERY_ACTIVE(1.725,"Hoạt động cao (6-7 ngày /tuần"),
    EXTREMELY_ACTIVE(1.9,"Hoạt động rất cao (vận động viên , lao động nặng")
    ;
    private final double multiplier;
    private final String description;

    ActivityLevel(double multiplier, String description) {
        this.multiplier = multiplier;
        this.description = description;
    }

    public double getMultiplier() {
        return multiplier;
    }

    public String getDescription() {
        return description;
    }
}