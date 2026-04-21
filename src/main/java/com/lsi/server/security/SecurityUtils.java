package com.lsi.server.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public final class SecurityUtils {
  private SecurityUtils() {
  }

  public static ApiPrincipal currentPrincipal() {
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    if (authentication == null || !(authentication.getPrincipal() instanceof ApiPrincipal)) {
      throw new SecurityException("Unauthorized");
    }
    return (ApiPrincipal) authentication.getPrincipal();
  }

  public static boolean isCurrentUserOrAdmin(long userId) {
    ApiPrincipal principal = currentPrincipal();
    return principal.isAdmin() || principal.getUserId() == userId;
  }

  public static void requireCurrentUserOrAdmin(long userId) {
    if (!isCurrentUserOrAdmin(userId)) {
      throw new SecurityException("Forbidden");
    }
  }

  public static void requireAdmin() {
    if (!currentPrincipal().isAdmin()) {
      throw new SecurityException("Forbidden");
    }
  }
}
