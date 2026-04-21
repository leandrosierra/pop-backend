package com.lsi.server.security;

public class OAuthIdentity {
  private final String provider;
  private final String subject;
  private final String email;
  private final String firstName;
  private final String lastName;
  private final String displayName;
  private final boolean emailVerified;

  public OAuthIdentity(String provider, String subject, String email, String firstName, String lastName, String displayName, boolean emailVerified) {
    this.provider = provider;
    this.subject = subject;
    this.email = email;
    this.firstName = firstName;
    this.lastName = lastName;
    this.displayName = displayName;
    this.emailVerified = emailVerified;
  }

  public String getProvider() {
    return provider;
  }

  public String getSubject() {
    return subject;
  }

  public String getEmail() {
    return email;
  }

  public String getFirstName() {
    return firstName;
  }

  public String getLastName() {
    return lastName;
  }

  public String getDisplayName() {
    return displayName;
  }

  public boolean isEmailVerified() {
    return emailVerified;
  }
}
