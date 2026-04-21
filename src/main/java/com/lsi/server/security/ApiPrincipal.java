package com.lsi.server.security;

public class ApiPrincipal {
  private final long userId;
  private final String role;

  public ApiPrincipal(long userId, String role) {
    this.userId = userId;
    this.role = role;
  }

  public long getUserId() {
    return userId;
  }

  public String getRole() {
    return role;
  }

  public boolean isAdmin() {
    return "ADMIN".equals(role);
  }
}
