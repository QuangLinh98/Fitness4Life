/**
 *
    Thư mục data_sources/
    Thư mục data_sources/ trong một module là nơi chứa các lớp (classes) chịu trách nhiệm giao tiếp với các nguồn dữ liệu cụ thể, bao gồm remote data source (API từ backend) và local data source (dữ liệu được lưu trữ cục bộ trên thiết bị). Dưới đây là giải thích chi tiết về cấu trúc và vai trò của từng thành phần trong thư mục này:

    1. remote_data_source.dart: Kết nối và gọi API từ backend
    Lớp trong file này chịu trách nhiệm:

    Gửi các yêu cầu HTTP đến backend (REST API hoặc GraphQL).
    Nhận phản hồi từ backend và chuyển dữ liệu trả về cho repository hoặc logic layer.
    Không chứa logic phức tạp, chỉ đơn thuần là gọi API.
    Các thành phần thường có trong remote_data_source.dart:
    Base URL hoặc endpoint API.
    Các phương thức gọi API tương ứng với các hành động, như:
    login, logout, resetPassword.
    Xử lý lỗi cơ bản (ví dụ: lỗi 404, 500, lỗi mạng).
 */
