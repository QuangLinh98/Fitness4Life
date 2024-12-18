package data.smartdeals_service.models.forum;

public enum CategoryForum {

    CCSDDTHV("các Chính Sách Diễn Đàn Thể Hình Vui"),
    NQDD("Nội Quy Diễn Đàn"),
    GANA("Giáo Án Fitness Nam"),
    GANU("Giáo Án Fitness Nữ"),
    GATH("Giáo án Thể Hình"),
    HDTH("Hỏi Đáp Thể Hình"),
    STTKTTLL("Sửa Tư Thế Kỹ Thuật Tập Luyện"),
    KINHNGHIEMĐINHUONG("Kinh Nghiệm Dinh Dưỡng"),
    RTPBS("Review Thực Phẩm Bổ Sung"),
    GM("Hỏi Đáp Giảm Cân - Giảm Mỡ"),
    TC("Hỏi Đáp Tăng Cơ - Tăng Cân"),
    NKTD("Nhật Ký Thay Đổi"),
    TGLQF("Tán Gẫu Liên Quan Fitness"),
    HLVTH("HLV Thể Hình - Trao Đổi Công Viêc"),
    CLBPGYQ("CLB Phòng Gym Toàn Quốc"),
    TBTC("Tìm Bạn Tập Cùng - Team Workout"),
    MBTPBS("Mua Bán Thực Phẩm Bổ Sung"),
    DCPKTL("Dụng Cụ - Phụ Kiện Tập Luyện"),
    SNPT("Sang Nhượng Phòng Tập"),
    VTTHMMA("Võ Thuật Tổng Hợp MMA"),
    CROSSFIT("Cross Fit"),
    POWERLIFITING("Power Fitting");

    private final String description; // Trường dữ liệu để lưu giá trị mô tả
    CategoryForum(String description) {
        this.description = description;
    }

    // Getter để lấy giá trị mô tả
    public String getDescription() {
        return description;
    }
}
