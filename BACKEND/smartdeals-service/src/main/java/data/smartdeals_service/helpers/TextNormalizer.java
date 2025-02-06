package data.smartdeals_service.helpers;

import java.text.Normalizer;
import java.util.regex.Pattern;

public class TextNormalizer {

    public static String removeDiacritics(String text) {
        if (text == null) {
            return null;
        }
        String normalized = Normalizer.normalize(text, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{M}");
        return pattern.matcher(normalized).replaceAll("").replaceAll("đ", "d").replaceAll("Đ", "D");
    }
}

