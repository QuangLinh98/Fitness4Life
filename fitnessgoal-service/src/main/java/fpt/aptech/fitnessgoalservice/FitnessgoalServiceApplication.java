package fpt.aptech.fitnessgoalservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableFeignClients  //Sử dụng để kịch hoạt Feign Client phục vụ cho việc các service khám phá dịch vụ lẫn nhau
@EnableDiscoveryClient  //Anotation Eureka
@EnableScheduling   //tự động gửi thông báo khi sử dụng Schedule
public class FitnessgoalServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(FitnessgoalServiceApplication.class, args);
    }

}
