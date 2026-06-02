# Angular / SPA integration

Connect an Angular (or any browser) app to **RaksAppSSO**.

## Keycloak settings

| Setting | Value |
|---------|--------|
| URL | `http://localhost:8080` |
| Realm | `myapps` |
| Client ID | e.g. `splitsek-ui` |
| Flow | Authorization Code + PKCE |

Discovery URL (for libraries):

```
http://localhost:8080/realms/myapps/.well-known/openid-configuration
```

## Option A — keycloak-js (simple)

```bash
npm install keycloak-js
```

```typescript
import Keycloak from 'keycloak-js';

const keycloak = new Keycloak({
  url: 'http://localhost:8080',
  realm: 'myapps',
  clientId: 'splitsek-ui'
});

await keycloak.init({ onLoad: 'login-required', pkceMethod: 'S256' });

// Attach token to API calls
const token = keycloak.token;
```

See `demo-app/app.js` for a working example.

## Option B — angular-oauth2-oidc

```bash
npm install angular-oauth2-oidc
```

Configure in `app.config.ts`:

```typescript
import { provideOAuthClient, OAuthService } from 'angular-oauth2-oidc';

// Issuer: http://localhost:8080/realms/myapps
// clientId: splitsek-ui
// responseType: 'code'
// scope: 'openid profile email'
// showDebugInformation: true (dev only)
```

Replace custom login forms with a redirect to Keycloak (`oauthService.initLoginFlow()`).

## Register a new SPA client

In Keycloak admin:

1. Client authentication: **OFF**
2. Standard flow: **ON**
3. Valid redirect URIs: `http://localhost:PORT/*`
4. Web origins: `http://localhost:PORT`
5. PKCE: S256 (recommended)

## SplitSek migration checklist

- [ ] Start RaksAppSSO
- [ ] Remove custom register/login UI (or keep register only in Keycloak)
- [ ] Use Keycloak token instead of custom JWT in `Authorization` header
- [ ] Update Spring Boot to validate Keycloak JWTs (see `spring-boot-oidc.md`)
