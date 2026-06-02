# RaksAppSSO

Central **Single Sign-On** for your applications, powered by **Keycloak**.

Log in once at Keycloak and access SplitSek, demo apps, or any other client registered in the `myapps` realm.

## Quick start

```bash
git clone <your-remote>/RaksAppSSO.git
cd RaksAppSSO
cp .env.example .env    # optional
./scripts/start.sh
```

**Docker permission error?** You are probably already in the `docker` group but this terminal has not refreshed. Use one of:

```bash
newgrp docker          # then ./scripts/start.sh again
# or log out and log back in
# or one-time with sudo:
DOCKER_SUDO=1 ./scripts/start.sh
```

**Admin console:** http://localhost:8080/admin (`admin` / `admin` by default)

**OIDC issuer:** http://localhost:8080/realms/myapps

## Pre-configured clients

| Client ID | Port | Purpose |
|-----------|------|---------|
| `splitsek-ui` | 4200 | SplitSek Angular app |
| `demo-app` | 4201 | Second app to test SSO |
| `splitsek-api` | — | Spring Boot API (bearer-only JWT validation) |

## Test users

| Email | Password |
|-------|----------|
| `alice@example.com` | `password123` |
| `bob@example.com` | `password123` |

## Test SSO (two apps)

```bash
# Terminal 1
./scripts/start.sh

# Terminal 2
cd demo-app && python3 -m http.server 4201
```

Open http://localhost:4201 → Sign in → open another registered app; you should stay logged in.

## Save realm in git (recommended)

After you change users, clients, or settings in the admin UI:

```bash
./scripts/export-realm.sh
git add realm/myapps-realm.json
git commit -m "Export Keycloak realm myapps"
```

This copies the **live** realm from Keycloak into `realm/myapps-realm.json` so you can version-control and restore it. See [docs/realm-backup.md](docs/realm-backup.md).

## Add another application

1. Open http://localhost:8080/admin → realm **myapps**
2. **Clients → Create client** (OpenID Connect, public for SPAs)
3. Set redirect URI: `http://localhost:YOUR_PORT/*`
4. Set web origins: `http://localhost:YOUR_PORT`

Or edit `realm/myapps-realm.json` and reset:

```bash
./scripts/stop.sh
docker volume rm raksappsso_keycloak_db_data
./scripts/start.sh
```

## Integrate your apps

- [Angular / SPA (OIDC)](docs/angular-oidc.md)
- [Spring Boot API (resource server)](docs/spring-boot-oidc.md)

## Layout

```
RaksAppSSO/
├── docker-compose.yml
├── realm/myapps-realm.json   # git backup — refresh with export-realm.sh
├── scripts/
│   ├── start.sh
│   ├── stop.sh
│   └── export-realm.sh       # save live realm → JSON for git
├── demo-app/
└── docs/
    └── realm-backup.md
```

## Stop

```bash
./scripts/stop.sh
```

## Production

Use HTTPS, strong admin passwords, and Keycloak `start` (not `start-dev`). Do not commit `.env`.
