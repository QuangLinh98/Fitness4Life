package data.smartdeals_service.helpers;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class EmojiUtils {

    // Chuyển emoji thành mã Unicode
    public static String emojiToUnicode(String text) {
        StringBuilder unicodeText = new StringBuilder();
        for (char c : text.toCharArray()) {
            if (Character.isSurrogate(c) || Character.isHighSurrogate(c)) {
                unicodeText.append(String.format("\\u%04X", (int) c));
            } else {
                unicodeText.append(c);
            }
        }
        return unicodeText.toString();
    }

    // Chuyển mã Unicode thành emoji
    public static String unicodeToEmoji(String text) {
        Pattern pattern = Pattern.compile("\\\\u([0-9A-Fa-f]{4})");
        Matcher matcher = pattern.matcher(text);
        StringBuffer emojiText = new StringBuffer();
        while (matcher.find()) {
            char emojiChar = (char) Integer.parseInt(matcher.group(1), 16);
            matcher.appendReplacement(emojiText, Character.toString(emojiChar));
        }
        matcher.appendTail(emojiText);
        return emojiText.toString();
    }
}

