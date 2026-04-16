# Deploying to Production

This app deploys with [Kamal](https://kamal-deploy.org). The Rails and Docker
configuration is ready; fill in your own values before the first deploy.

## Prerequisites

- A server reachable over SSH (any Ubuntu/Debian VPS works)
- A container registry account (Docker Hub, GHCR, DigitalOcean, etc.)
- A domain pointed at the server with an A/AAAA record
- A [Jupiter API key](https://portal.jup.ag) for token metadata and prices
  (optional but recommended)

This app runs on devnet by default (public `api.devnet.solana.com`), so no
paid RPC provider is needed. If you switch `SOLANA_NETWORK` to mainnet, the
public endpoint is heavily rate-limited — use Helius, QuickNode, Triton, or
similar and inject the URL via `SOLANA_RPC_URL` / `SOLANA_WS_URL`.

## Step 1: generate Rails credentials

```sh
bin/rails credentials:edit
```

This creates `config/master.key` (gitignored) and `config/credentials.yml.enc`
(committed). **Back the key up securely** — losing it means losing every
encrypted value.

## Step 2: configure `config/deploy.yml`

Copy the example and fill in your values:

```sh
cp config/deploy.yml.example config/deploy.yml
```

| Key | What to set |
| --- | --- |
| `service` | Short app name, e.g. `my_solana_app` |
| `image`  | `your-user/my_solana_app` (must match registry path) |
| `servers.web` | Your server IP or hostname |
| `proxy.host` | Your production domain (e.g. `app.example.com`) |
| `proxy.ssl` | `true` (Kamal provisions Let's Encrypt automatically) |
| `registry.server` | `ghcr.io`, `docker.io`, `registry.digitalocean.com`, etc. |
| `env.clear.APP_DOMAIN` | Your production domain (same as `proxy.host`) |
| `ssh.user` | SSH user on the server |

Production SSL, DNS rebinding protection, HSTS, and mailer host are all
driven by the `APP_DOMAIN` env var in `config/environments/production.rb`.

## Step 3: set secrets

Create `.kamal/secrets` (it's gitignored). At minimum:

```sh
KAMAL_REGISTRY_PASSWORD=$KAMAL_REGISTRY_PASSWORD
RAILS_MASTER_KEY=$(cat config/master.key)
JUPITER_API_KEY=$JUPITER_API_KEY
```

Export the shell variables before deploying, or use a password manager
(1Password, Bitwarden CLI, etc.) — see the comments in
`.kamal/hooks/*.sample` for patterns.

## Step 4: deploy

```sh
bin/kamal setup     # first time — bootstraps Docker, pushes image, starts
bin/kamal deploy    # subsequent deploys
```

Watch logs with `bin/kamal logs`.

## Step 5: verify

- `https://your-domain/up` returns 200 (Rails health check)
- Landing page loads with styles intact
- Connect a wallet → redirects to `/dashboard` with a SOL balance
- Open DevTools console → check for CSP violations (CSP starts in
  **report-only** mode). Once clean, flip
  `config.content_security_policy_report_only = false` in
  `config/initializers/content_security_policy.rb` and redeploy

## Notes

- **SIWS signatures are tied to `APP_DOMAIN`.** If it doesn't match the URL
  the browser shows, wallet sign-in will fail. Must be the exact host — no
  scheme, no port (e.g. `app.example.com`).
- **SQLite + Solid Queue/Cache/Cable is single-server only.** The Kamal
  `volumes` block persists `/rails/storage`. For durability, add off-server
  backups (Litestream, rclone to S3, etc.).
- **`config/master.key` must never be committed.** It's in `.gitignore` and
  `.dockerignore`; double-check before pushing.
