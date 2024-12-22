package data.smartdeals_service.models.forum;

public enum CategoryForum {

    FORUM_POLICY("Các Chính Sách Diễn Đàn Thể Hình Vui"),
    FORUM_RULES("Nội Quy Diễn Đàn"),
    MALE_FITNESS_PROGRAM("Giáo Án Fitness Nam"),
    FEMALE_FITNESS_PROGRAM("Giáo Án Fitness Nữ"),
    GENERAL_FITNESS_PROGRAM("Giáo án Thể Hình"),
    FITNESS_QA("Hỏi Đáp Thể Hình"),
    POSTURE_CORRECTION("Sửa Tư Thế Kỹ Thuật Tập Luyện"),
    NUTRITION_EXPERIENCE("Kinh Nghiệm Dinh Dưỡng"),
    SUPPLEMENT_REVIEW("Review Thực Phẩm Bổ Sung"),
    WEIGHT_LOSS_QA("Hỏi Đáp Giảm Cân - Giảm Mỡ"),
    MUSCLE_GAIN_QA("Hỏi Đáp Tăng Cơ - Tăng Cân"),
    TRANSFORMATION_JOURNAL("Nhật Ký Thay Đổi"),
    FITNESS_CHATS("Tán Gẫu Liên Quan Fitness"),
    TRAINER_DISCUSSION("HLV Thể Hình - Trao Đổi Công Việc"),
    NATIONAL_GYM_CLUBS("CLB Phòng Gym Toàn Quốc"),
    FIND_WORKOUT_BUDDY("Tìm Bạn Tập Cùng - Team Workout"),
    SUPPLEMENT_MARKET("Mua Bán Thực Phẩm Bổ Sung"),
    EQUIPMENT_ACCESSORIES("Dụng Cụ - Phụ Kiện Tập Luyện"),
    GYM_TRANSFER("Sang Nhượng Phòng Tập"),
    MMA_DISCUSSION("Võ Thuật Tổng Hợp MMA"),
    CROSSFIT_DISCUSSION("Cross Fit"),
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
