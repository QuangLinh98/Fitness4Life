package fpt.aptech.dashboardservice.service.SlugUtil;

import java.text.Normalizer;

public class Slug {
    /**
     * Phương thức generateSlug sẽ tạo ra một slug thân thiện với URL bằng cách chuyển tên sản phẩm thành dạng không dấu,
     * loại bỏ ký tự đặc biệt, thay thế khoảng trắng bằng dấu gạch ngang và kết hợp với ID để đảm bảo tính duy nhất của slug.
     */
    public static String generateSlug(String name, int id) {
        String result = Normalizer.normalize(name, Normalizer.Form.NFD)
                .toLowerCase()                                       // Chuyển tất cả ký tự thành chữ thường
                .replaceAll("\\p{IsM}+", "")        // Loại bỏ dấu tiếng Việt (hoặc các ký tự dấu khác)
                .replaceAll("\\p{IsP}+", " ")       // Loại bỏ các ký tự đặc biệt (dấu chấm, dấu phẩy, ...)
                .trim()                                              // Loại bỏ khoảng trắng thừa ở đầu và cuối chuỗi
                .replaceAll("\\s+", "-");           // Chuyển khoảng trắng thành dấu gạch ngang
        return result + "-" + id;                                    // Kết hợp với ID để tạo slug duy nhất
    }
}
