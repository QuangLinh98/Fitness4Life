package data.smartdeals_service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class SmartdealsServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(SmartdealsServiceApplication.class, args);
	}

}
