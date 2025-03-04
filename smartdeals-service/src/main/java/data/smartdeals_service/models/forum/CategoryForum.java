package data.smartdeals_service.models.forum;

public enum CategoryForum {
    FORUM_POLICY("Fun Fitness Forum Policies"),
    FORUM_RULES("Forum Rules"),
    MALE_FITNESS_PROGRAM("Men's Fitness Program"),
    FEMALE_FITNESS_PROGRAM("Women's Fitness Program"),
    GENERAL_FITNESS_PROGRAM("General Bodybuilding Program"),
    FITNESS_QA("Fitness Q&A"),
    POSTURE_CORRECTION("Exercise Form & Technique Correction"),
    NUTRITION_EXPERIENCE("Nutrition Experience"),
    SUPPLEMENT_REVIEW("Supplement Reviews"),
    WEIGHT_LOSS_QA("Weight Loss & Fat Loss Q&A"),
    MUSCLE_GAIN_QA("Muscle Gain & Weight Gain Q&A"),
    TRANSFORMATION_JOURNAL("Transformation Journal"),
    FITNESS_CHATS("Fitness Related Chats"),
    TRAINER_DISCUSSION("Fitness Trainers - Job Exchange"),
    NATIONAL_GYM_CLUBS("National Gym Clubs"),
    FIND_WORKOUT_BUDDY("Find Workout Partners - Team Workout"),
    SUPPLEMENT_MARKET("Supplement Marketplace"),
    EQUIPMENT_ACCESSORIES("Training Equipment & Accessories"),
    GYM_TRANSFER("Gym Transfer & Sales"),
    MMA_DISCUSSION("Mixed Martial Arts (MMA)"),
    CROSSFIT_DISCUSSION("CrossFit"),
    POWERLIFTING_DISCUSSION("Powerlifting");

    private final String description; // Trường dữ liệu để lưu giá trị mô tả
    CategoryForum(String description) {
        this.description = description;
    }

    // Getter để lấy giá trị mô tả
    public String getDescription() {
        return description;
    }
}
