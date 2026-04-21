package com.lsi.server.security;

import java.util.Arrays;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;

@Configuration
public class SecurityConfig extends WebSecurityConfigurerAdapter {
  private static final List<String> LOCAL_ORIGINS = Arrays.asList(
      "http://localhost:8082",
      "http://127.0.0.1:8082",
      "http://localhost:8090",
      "http://127.0.0.1:8090",
      "http://localhost:8182",
      "http://127.0.0.1:8182",
      "http://localhost:8190",
      "http://127.0.0.1:8190",
      "http://localhost:8282",
      "http://127.0.0.1:8282",
      "http://localhost:8290",
      "http://127.0.0.1:8290");

  @Override
  protected void configure(HttpSecurity http) throws Exception {
    http
      .cors().and()
      .csrf().disable()
      .authorizeRequests()
        .antMatchers(HttpMethod.POST, "/user/**").authenticated()
        .antMatchers(HttpMethod.PUT, "/user/**").authenticated()
        .antMatchers(HttpMethod.DELETE, "/user/**").authenticated()
        .antMatchers(HttpMethod.GET, "/user/**").authenticated()
        .anyRequest().permitAll()
        .and()
      .httpBasic().and()
      .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS);
  }

  @Bean
  CorsConfigurationSource corsConfigurationSource() {
    return new CorsConfigurationSource() {
      @Override
      public CorsConfiguration getCorsConfiguration(HttpServletRequest request) {
        CorsConfiguration configuration = new CorsConfiguration();
        String origin = request.getHeader("Origin");
        configuration.setAllowedOrigins(isAllowedOrigin(origin) ? Arrays.asList(origin) : LOCAL_ORIGINS);
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type", "Accept"));
        configuration.setAllowCredentials(true);
        return configuration;
      }
    };
  }

  private boolean isAllowedOrigin(String origin) {
    return LOCAL_ORIGINS.contains(origin);
  }
}
