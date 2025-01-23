package data.smartdeals_service.component;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class ApplicationProperties {

    @Value("${json.folder}")
    private String jsonFolder;

    public String getJsonFolder() {
        return jsonFolder;
    }

    public void setJsonFolder(String jsonFolder) {
        this.jsonFolder = jsonFolder;
    }
}
