package com.lsi.server.security;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.Base64;

import javax.annotation.PostConstruct;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class TokenService {
  private static final String HMAC_ALGORITHM = "HmacSHA256";

  @Value("${pop.token.secret}")
  private String secret;

  @Value("${pop.token.ttl-seconds}")
  private long tokenTtlSeconds;

  private byte[] secretBytes;

  @PostConstruct
  public void init() {
    if (secret == null || secret.trim().length() < 32) {
      throw new IllegalStateException("POP_TOKEN_SECRET must contain at least 32 characters.");
    }
    secretBytes = secret.getBytes(StandardCharsets.UTF_8);
  }

  public String createToken(long userId, String role) {
    long expiresAt = Instant.now().getEpochSecond() + tokenTtlSeconds;
    String payload = userId + ":" + role + ":" + expiresAt;
    String encodedPayload = base64Url(payload.getBytes(StandardCharsets.UTF_8));
    return encodedPayload + "." + sign(encodedPayload);
  }

  public ApiPrincipal verify(String token) {
    String[] parts = token == null ? new String[0] : token.split("\\.", -1);
    if (parts.length != 2 || !MessageDigest.isEqual(sign(parts[0]).getBytes(StandardCharsets.UTF_8), parts[1].getBytes(StandardCharsets.UTF_8))) {
      throw new SecurityException("Invalid token");
    }
    String payload = new String(Base64.getUrlDecoder().decode(parts[0]), StandardCharsets.UTF_8);
    String[] values = payload.split(":", -1);
    if (values.length != 3) {
      throw new SecurityException("Invalid token");
    }
    long expiresAt = Long.parseLong(values[2]);
    if (expiresAt < Instant.now().getEpochSecond()) {
      throw new SecurityException("Expired token");
    }
    return new ApiPrincipal(Long.parseLong(values[0]), values[1]);
  }

  private String sign(String payload) {
    try {
      Mac mac = Mac.getInstance(HMAC_ALGORITHM);
      mac.init(new SecretKeySpec(secretBytes, HMAC_ALGORITHM));
      return base64Url(mac.doFinal(payload.getBytes(StandardCharsets.UTF_8)));
    } catch (Exception e) {
      throw new SecurityException("Token signing failed", e);
    }
  }

  private String base64Url(byte[] input) {
    return Base64.getUrlEncoder().withoutPadding().encodeToString(input);
  }
}
