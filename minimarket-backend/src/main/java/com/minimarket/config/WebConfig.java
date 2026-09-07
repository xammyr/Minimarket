package com.minimarket.config;
import org.springframework.context.annotation.*;
import org.springframework.web.cors.*;
import java.util.List;
@Configuration
public class WebConfig {
 @Bean public CorsConfigurationSource corsConfigurationSource(){
   var c=new CorsConfiguration(); c.setAllowedOrigins(List.of("http://localhost:5173","http://localhost:3000"));
   c.setAllowedMethods(List.of("GET","POST","PUT","PATCH","DELETE","OPTIONS"));
   c.setAllowedHeaders(List.of("Authorization","Content-Type","Accept")); c.setAllowCredentials(true);
   var s=new UrlBasedCorsConfigurationSource();s.registerCorsConfiguration("/**",c);return s;
 }
}
