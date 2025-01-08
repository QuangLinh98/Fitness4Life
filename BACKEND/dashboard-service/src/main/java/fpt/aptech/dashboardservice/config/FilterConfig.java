//package fpt.aptech.dashboardservice.config;
//
//import fpt.aptech.dashboardservice.filter.ServiceSourceFilter;
//import org.springframework.boot.web.servlet.FilterRegistrationBean;
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//
//@Configuration
//public class FilterConfig {
//    @Bean
//    public FilterRegistrationBean<ServiceSourceFilter> serviceSourceFilter() {
//        FilterRegistrationBean<ServiceSourceFilter> registrationBean = new FilterRegistrationBean<>();
//        registrationBean.setFilter(new ServiceSourceFilter());
//        registrationBean.addUrlPatterns("/api/dashboard/room/*"); // Áp dụng filter cho endpoint này
//        return registrationBean;
//    }
//}
