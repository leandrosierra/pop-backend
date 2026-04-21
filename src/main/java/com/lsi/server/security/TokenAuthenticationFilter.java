package com.lsi.server.security;

import java.io.IOException;
import java.util.Collections;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import com.lsi.server.model.User;
import com.lsi.server.repository.UserRepository;

public class TokenAuthenticationFilter extends OncePerRequestFilter {
  private final TokenService tokenService;
  private final UserRepository userRepository;

  public TokenAuthenticationFilter(TokenService tokenService, UserRepository userRepository) {
    this.tokenService = tokenService;
    this.userRepository = userRepository;
  }

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
      throws ServletException, IOException {
    String authorization = request.getHeader("Authorization");
    if (authorization != null && authorization.startsWith("Bearer ")) {
      try {
        ApiPrincipal tokenPrincipal = tokenService.verify(authorization.substring("Bearer ".length()).trim());
        User user = userRepository.findById(tokenPrincipal.getUserId()).orElse(null);
        if (user != null && user.isActif()) {
          String role = user.getRole() != null && user.getRole().getCode() != null ? user.getRole().getCode() : "USER";
          ApiPrincipal principal = new ApiPrincipal(user.getId(), role);
          UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
              principal,
              null,
              Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + principal.getRole())));
          SecurityContextHolder.getContext().setAuthentication(authentication);
        }
      } catch (RuntimeException e) {
        SecurityContextHolder.clearContext();
      }
    }
    filterChain.doFilter(request, response);
  }
}
