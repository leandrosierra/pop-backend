package com.lsi.server.security;

import java.net.MalformedURLException;
import java.net.URL;
import java.security.interfaces.RSAPublicKey;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.auth0.jwk.Jwk;
import com.auth0.jwk.JwkException;
import com.auth0.jwk.JwkProvider;
import com.auth0.jwk.JwkProviderBuilder;
import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;

@Service
public class OAuthIdentityService {
  private static final String GOOGLE_JWKS_URL = "https://www.googleapis.com/oauth2/v3/certs";
  private static final String APPLE_JWKS_URL = "https://appleid.apple.com/auth/keys";

  private final JwkProvider googleJwkProvider = jwkProvider(GOOGLE_JWKS_URL);
  private final JwkProvider appleJwkProvider = jwkProvider(APPLE_JWKS_URL);
  private final RestTemplate restTemplate = new RestTemplate();

  @Value("${pop.oauth.google.client-ids:}")
  private String googleClientIds;

  @Value("${pop.oauth.apple.client-ids:}")
  private String appleClientIds;

  @Value("${pop.oauth.facebook.app-id:}")
  private String facebookAppId;

  @Value("${pop.oauth.facebook.app-secret:}")
  private String facebookAppSecret;

  @Value("${pop.oauth.instagram.app-id:}")
  private String instagramAppId;

  @Value("${pop.oauth.instagram.app-secret:}")
  private String instagramAppSecret;

  public OAuthIdentity verify(OAuthLoginRequest request) {
    String provider = normalized(request == null ? null : request.getProvider());
    if ("google".equals(provider)) {
      return verifyGoogle(request);
    }
    if ("apple".equals(provider)) {
      return verifyApple(request);
    }
    if ("facebook".equals(provider)) {
      return verifyFacebook(request);
    }
    if ("instagram".equals(provider)) {
      return verifyInstagram(request);
    }
    throw new SecurityException("Unauthorized");
  }

  private OAuthIdentity verifyGoogle(OAuthLoginRequest request) {
    List<String> clientIds = configuredValues(googleClientIds);
    DecodedJWT jwt = verifyJwt(required(request.getIdToken()), googleJwkProvider, Arrays.asList("https://accounts.google.com", "accounts.google.com"), clientIds);
    return new OAuthIdentity(
        "google",
        required(jwt.getSubject()),
        normalized(jwt.getClaim("email").asString()),
        normalized(jwt.getClaim("given_name").asString()),
        normalized(jwt.getClaim("family_name").asString()),
        normalized(jwt.getClaim("name").asString()),
        claimBoolean(jwt, "email_verified"));
  }

  private OAuthIdentity verifyApple(OAuthLoginRequest request) {
    List<String> clientIds = configuredValues(appleClientIds);
    DecodedJWT jwt = verifyJwt(required(request.getIdToken()), appleJwkProvider, Collections.singletonList("https://appleid.apple.com"), clientIds);
    String firstName = normalized(request.getFirstName());
    String lastName = normalized(request.getLastName());
    String displayName = normalized(request.getName());
    if (displayName == null) {
      displayName = joinName(firstName, lastName);
    }
    return new OAuthIdentity(
        "apple",
        required(jwt.getSubject()),
        normalized(jwt.getClaim("email").asString()),
        firstName,
        lastName,
        displayName,
        claimBoolean(jwt, "email_verified"));
  }

  private OAuthIdentity verifyFacebook(OAuthLoginRequest request) {
    String appId = requiredConfigured(facebookAppId);
    String appSecret = requiredConfigured(facebookAppSecret);
    String accessToken = required(request.getAccessToken());
    try {
      String debugUrl = UriComponentsBuilder.fromHttpUrl("https://graph.facebook.com/debug_token")
          .queryParam("input_token", accessToken)
          .queryParam("access_token", appId + "|" + appSecret)
          .toUriString();
      Map<String, Object> debugResponse = restTemplate.getForObject(debugUrl, Map.class);
      Map<String, Object> data = mapValue(debugResponse, "data");
      if (!Boolean.TRUE.equals(data.get("is_valid")) || !appId.equals(String.valueOf(data.get("app_id")))) {
        throw new SecurityException("Unauthorized");
      }

      String userUrl = UriComponentsBuilder.fromHttpUrl("https://graph.facebook.com/me")
          .queryParam("fields", "id,name,email,first_name,last_name")
          .queryParam("access_token", accessToken)
          .toUriString();
      Map<String, Object> userResponse = restTemplate.getForObject(userUrl, Map.class);
      return new OAuthIdentity(
          "facebook",
          required(stringValue(userResponse, "id")),
          normalized(stringValue(userResponse, "email")),
          normalized(stringValue(userResponse, "first_name")),
          normalized(stringValue(userResponse, "last_name")),
          normalized(stringValue(userResponse, "name")),
          normalized(stringValue(userResponse, "email")) != null);
    } catch (RestClientException exception) {
      throw new SecurityException("Unauthorized");
    }
  }

  private OAuthIdentity verifyInstagram(OAuthLoginRequest request) {
    String appId = requiredConfigured(instagramAppId);
    String appSecret = requiredConfigured(instagramAppSecret);
    try {
      MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
      body.add("client_id", appId);
      body.add("client_secret", appSecret);
      body.add("grant_type", "authorization_code");
      body.add("redirect_uri", required(request.getRedirectUri()));
      body.add("code", required(request.getAuthorizationCode()));

      HttpHeaders headers = new HttpHeaders();
      headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
      Map<String, Object> tokenResponse = restTemplate.postForObject(
          "https://api.instagram.com/oauth/access_token",
          new HttpEntity<MultiValueMap<String, String>>(body, headers),
          Map.class);
      String accessToken = required(stringValue(tokenResponse, "access_token"));
      String tokenUserId = normalized(stringValue(tokenResponse, "user_id"));

      String userUrl = UriComponentsBuilder.fromHttpUrl("https://graph.instagram.com/me")
          .queryParam("fields", "id,username")
          .queryParam("access_token", accessToken)
          .toUriString();
      Map<String, Object> userResponse = restTemplate.getForObject(userUrl, Map.class);
      String subject = normalized(stringValue(userResponse, "id"));
      if (subject == null) {
        subject = tokenUserId;
      }
      String username = normalized(stringValue(userResponse, "username"));
      return new OAuthIdentity("instagram", required(subject), null, null, null, username, false);
    } catch (RestClientException exception) {
      throw new SecurityException("Unauthorized");
    }
  }

  private DecodedJWT verifyJwt(String token, JwkProvider provider, List<String> issuers, List<String> audiences) {
    try {
      DecodedJWT decoded = JWT.decode(token);
      Jwk jwk = provider.get(required(decoded.getKeyId()));
      Algorithm algorithm = Algorithm.RSA256((RSAPublicKey) jwk.getPublicKey(), null);
      DecodedJWT verified = JWT.require(algorithm).build().verify(token);
      if (!issuers.contains(verified.getIssuer())) {
        throw new SecurityException("Unauthorized");
      }
      if (verified.getAudience() == null || verified.getAudience().stream().noneMatch(audiences::contains)) {
        throw new SecurityException("Unauthorized");
      }
      return verified;
    } catch (JwkException | RuntimeException exception) {
      throw new SecurityException("Unauthorized");
    }
  }

  private static JwkProvider jwkProvider(String url) {
    try {
      return new JwkProviderBuilder(new URL(url))
          .cached(10, 24, TimeUnit.HOURS)
          .rateLimited(10, 1, TimeUnit.MINUTES)
          .build();
    } catch (MalformedURLException exception) {
      throw new IllegalStateException(exception);
    }
  }

  private List<String> configuredValues(String value) {
    List<String> values = Arrays.stream((value == null ? "" : value).split(","))
        .map(OAuthIdentityService::normalized)
        .filter(item -> item != null)
        .collect(Collectors.toList());
    if (values.isEmpty()) {
      throw new SecurityException("Unauthorized");
    }
    return values;
  }

  private String requiredConfigured(String value) {
    return required(normalized(value));
  }

  private static String required(String value) {
    String normalized = normalized(value);
    if (normalized == null) {
      throw new SecurityException("Unauthorized");
    }
    return normalized;
  }

  private static String normalized(String value) {
    if (value == null) {
      return null;
    }
    String trimmed = value.trim();
    return trimmed.isEmpty() ? null : trimmed;
  }

  private static boolean claimBoolean(DecodedJWT jwt, String name) {
    Boolean value = jwt.getClaim(name).asBoolean();
    if (value != null) {
      return value;
    }
    return "true".equalsIgnoreCase(jwt.getClaim(name).asString());
  }

  private static String joinName(String firstName, String lastName) {
    return normalized(Arrays.asList(firstName, lastName).stream()
        .filter(value -> value != null)
        .collect(Collectors.joining(" ")));
  }

  private static String stringValue(Map<String, Object> map, String key) {
    if (map == null || !map.containsKey(key) || map.get(key) == null) {
      return null;
    }
    return String.valueOf(map.get(key));
  }

  @SuppressWarnings("unchecked")
  private static Map<String, Object> mapValue(Map<String, Object> map, String key) {
    if (map == null) {
      return Collections.emptyMap();
    }
    Object value = map.get(key);
    return value instanceof Map ? (Map<String, Object>) value : Collections.emptyMap();
  }
}
