# Realm backup in git (recommended)

Keep **`realm/myapps-realm.json`** in git as the source of truth for your SSO setup.

## Daily workflow

1. **Run Keycloak** and change things in the admin UI (users, clients, roles).
2. **Export** the live realm to the JSON file:
   ```bash
   ./scripts/export-realm.sh
   ```
3. **Commit** to git:
   ```bash
   git add realm/myapps-realm.json
   git commit -m "Export Keycloak realm myapps"
   git push
   ```

## What gets saved

The export includes:

- Realm settings
- Clients (splitsek-ui, demo-app, etc.)
- Roles and groups
- Users (including test users)

Passwords are included in the export file. This is fine for **local dev**; do not push production secrets to a public repo.

## Where data lives

| Storage | Purpose |
|---------|---------|
| Docker volume `raksappsso_keycloak_db_data` | Live database while you work |
| `realm/myapps-realm.json` in git | Backup + recreate on new machines |

Changes in the admin UI go to the **Docker volume** immediately.  
They only reach **git** when you run `./scripts/export-realm.sh`.

## Restore from git backup

On a new machine (or after wiping data):

```bash
git clone <your-repo>/RaksAppSSO.git
cd RaksAppSSO
./scripts/start.sh          # imports myapps-realm.json on first start
```

To force re-import from the JSON file:

```bash
./scripts/stop.sh
docker volume rm raksappsso_keycloak_db_data
./scripts/start.sh
```

## Manual export (admin UI)

1. http://localhost:8080/admin → realm **myapps**
2. **Realm settings** → **Action** → **Partial export**
3. Enable clients, roles, users → **Export**
4. Save as `realm/myapps-realm.json`

The script does the same thing automatically.

## Tips

- Run `export-realm.sh` after adding a client or user you care about.
- Use `DOCKER_SUDO=1 ./scripts/export-realm.sh` if Docker needs sudo (same as start script).
- Never run `docker compose down -v` unless you intentionally want to wipe local data.
