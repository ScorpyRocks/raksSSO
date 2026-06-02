# Spring Boot API integration

Validate **Keycloak JWTs** in a Spring Boot backend instead of custom signed tokens.

## Issuer

```
http://localhost:8080/realms/myapps
```

Spring resolves JWKS automatically from:

```
http://localhost:8080/realms/myapps/.well-known/openid-configuration
```

## Dependencies (pom.xml)

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>
```

## application.properties

```properties
spring.security.oauth2.resourceserver.jwt.issuer-uri=http://localhost:8080/realms/myapps
```

## SecurityConfig (simplified)

```java
@Bean
SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
        .csrf(csrf -> csrf.disable())
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/api/auth/**").permitAll()
            .requestMatchers("/api/**").authenticated()
            .anyRequest().permitAll())
        .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()))
        .build();
}
```

Remove custom `JwtService` token signing when fully migrated.

## Read user from token

```java
@GetMapping("/api/me")
public Map<String, Object> me(@AuthenticationPrincipal Jwt jwt) {
    return Map.of(
        "email", jwt.getClaimAsString("email"),
        "name", jwt.getClaimAsString("preferred_username")
    );
}
```

Keycloak puts email in the `email` claim and username in `preferred_username`.

## Keycloak client

Use the pre-configured **`splitsek-api`** client (bearer-only). SPAs use **`splitsek-ui`** to get tokens; the API only validates them.

## CORS

Allow your frontend origin (e.g. `http://localhost:4200`) in Spring `CorsConfig` as you do today.

## Local dev order

1. `./scripts/start.sh` (RaksAppSSO)
2. Start Spring Boot API on 8081
3. Start Angular on 4200 with Keycloak login
