package data.smartdeals_service.services.spam;

import com.fasterxml.jackson.databind.ObjectMapper;
import data.smartdeals_service.helpers.TextNormalizer;
import data.smartdeals_service.models.charSpam.SpamKeywords;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;

@Service
public class SpamFilterService {

    private List<String> spamKeywordsVN;
    private List<String> spamKeywordsEN;

    public SpamFilterService() {
        loadSpamKeywords();
    }

    private void loadSpamKeywords() {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            SpamKeywords keywords = objectMapper.readValue(
                    Paths.get("src/main/resources/spam_keywordsVN.json").toFile(),
                    SpamKeywords.class
            );
            this.spamKeywordsVN = keywords.getSpamKeywords();

            // Load từ khóa tiếng Anh
            SpamKeywords keywordsEN = objectMapper.readValue(
                    Paths.get("src/main/resources/spam_keywordsEN.json").toFile(),
                    SpamKeywords.class
            );
            this.spamKeywordsEN = keywordsEN.getSpamKeywords();
        } catch (IOException e) {
            e.printStackTrace();
            throw new RuntimeException("Unable to load spam keywords");
        }
    }
    public String detectLanguage(String content) {
        // Chuẩn hóa nội dung: Loại bỏ dấu và chuyển thành chữ thường
        String normalizedContent = TextNormalizer.removeDiacritics(content).toLowerCase();

        // Danh sách từ phổ biến tiếng Việt không dấu
        String[] commonVietnameseWords = {
                "anh", "em", "toi", "ban", "chung", "ta", "ho", "cua", "cai", "nay", "kia", "do", "la", "co",
                "khong", "gi", "sao", "the", "nao", "tai", "sao", "vi", "vay", "voi", "trong", "ngoai", "tren",
                "duoi", "lam", "di", "an", "uong", "hoc", "doc", "viet", "noi", "nghe", "xem", "chay", "dung",
                "ngoi", "ngu", "choi", "vui", "buon", "yeu", "ghet", "thich", "nho", "quen", "biet", "hieu",
                "can", "muon", "phai", "nen", "the", "duoc", "hay", "rat", "nhieu", "it", "tot", "xau", "moi",
                "cu", "nhanh", "cham", "to", "nho", "dai", "ngan", "cao", "thap", "gan", "xa", "nong", "lanh",
                "dep", "xau", "hom", "nay", "ngay", "mai", "qua", "gio", "phut", "giay", "tuan", "thang", "nam"
        };

        // Kiểm tra nếu nội dung chứa các từ phổ biến tiếng Việt
        for (String word : commonVietnameseWords) {
            if (normalizedContent.contains(word)) {
                return "VN"; // Tiếng Việt không dấu
            }
        }

        // Phát hiện các chuỗi ký tự đặc trưng tiếng Việt
        String[] vietnameseCharacterPatterns = {
                "ng", "nh", "kh", "ch", "th", "ph", "qu", "gi", "tr", "hu", "ho", "ti", "tu", "ca", "co", "cu",
                "da", "di", "du", "ba", "be", "bo", "bu", "la", "le", "lo", "lu", "ma", "me", "mo", "mu", "na",
                "ne", "no", "nu", "sa", "se", "so", "su", "va", "ve", "vo", "vu"
        };

        for (String pattern : vietnameseCharacterPatterns) {
            if (normalizedContent.contains(pattern)) {
                return "VN"; // Tiếng Việt không dấu dính liền
            }
        }

        // Nếu không phát hiện tiếng Việt, trả về EN
        return "EN";
    }



    public boolean isSpam(String content, String language) {
        List<String> keywords = language.equalsIgnoreCase("EN") ? spamKeywordsEN : spamKeywordsVN;

        for (String keyword : keywords) {
            if (content.toLowerCase().contains(keyword.toLowerCase())) {
                return true; // Nội dung là spam
            }
        }
        return false; // Nội dung hợp lệ
    }
}

