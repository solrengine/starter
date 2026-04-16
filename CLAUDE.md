# CLAUDE.md

## Project Overview

Rails 8 Solana dApp starter built with the SolRengine framework. Wallet-based
authentication (SIWS), client-side transaction signing, token display, and a
component showcase are all pre-wired.

## Key Commands

- `bin/dev` — start all processes (web, js, css)
- `yarn build` — bundle JS with esbuild
- `yarn build:css` — compile Tailwind via `bin/build-css` (resolves
  solrengine-ui gem path via Bundler, appends @source globs for .rb/.erb)
- `bin/rails db:prepare` — set up all databases (primary + cache + queue + cable)
- `bin/rails test` — run Minitest suite
- `bin/kamal deploy` — ship to production (see DEPLOY.md)

## Environment Variables

All have sensible devnet defaults. Only `APP_DOMAIN` needs to change for
production. Copy `.env.example` to `.env`.

- `SOLANA_NETWORK` — devnet (default) / testnet / mainnet
- `APP_DOMAIN` — SIWS domain + DNS rebinding host + mailer host
- `JUPITER_API_KEY` — token metadata/prices via solrengine-tokens
- `SOLANA_RPC_URL` / `SOLANA_WS_URL` — optional mainnet RPC override

`.env*`, `config/deploy.yml`, `.kamal/secrets` are all gitignored.

## Tech Stack

- Ruby on Rails 8.1, Ruby 3.3.6
- Hotwire (Turbo + Stimulus), ViewComponent, Lookbook
- @solana/kit, @wallet-standard/app, @solrengine/wallet-utils
- Tailwind CSS 4 via esbuild + Propshaft
- SQLite + Solid Cache + Solid Queue + Solid Cable
- Kamal + Thruster

## SolRengine Packages

Ruby gems (all from RubyGems):
- **solrengine-auth** — SIWS authentication
- **solrengine-rpc** — JSON-RPC client. Use `Solrengine::Rpc.client` singleton
  (has built-in default URLs per network) instead of constructing clients
  with `ENV.fetch(...)`.
- **solrengine-programs** — Anchor IDL parsing, Borsh serialization
- **solrengine-ui** — ViewComponent UI library
- **solrengine-tokens** — SPL token metadata via Jupiter API
- **view_component** — explicit runtime dep (solrengine-ui depends on it
  transitively but doesn't auto-require; production fails without it)

NPM packages:
- **@solrengine/wallet-utils** — WalletController, SendTransactionController,
  buildTransferTransaction, signAndSend
- **@solrengine/ui** — Stimulus controllers for gem components (sui-modal,
  sui-clipboard, sui-dropdown, etc.), registered via registerControllers()

## Architecture

### Wallet auth (SIWS)

WalletController discovers wallets via Wallet Standard, legacy provider for
connect() (Chrome gesture context), wallet-standard for signMessage.
SessionsController handles nonce/verify/destroy. User identified by
wallet_address (unique).

### Send SOL (client-side)

No Rails endpoint involved:
1. SendTransactionFormComponent emits a form with data-controller="send-transaction"
2. SendTransactionController intercepts submit, fetches blockhash via RPC,
   builds transfer with @solana/kit, calls signAndSend
3. Status + explorer link rendered inline

### Devnet airdrop

POST /airdrop → AirdropsController#create → requestAirdrop RPC call.
skip_forgery_protection because the gem's AirdropButtonComponent doesn't emit
a CSRF token. Safe: only triggers devnet airdrop to the logged-in user.

### Tailwind gem scanning

bin/build-css resolves solrengine-ui gem path via Gem.loaded_specs at build
time, appends @source globs for .erb and .rb files. Survives gem version bumps.

### Lookbook

Mounted at /lookbook in all environments. Personalized via
config/initializers/lookbook.rb: purple accent theme, version-aware title,
centered preview layout.

## Program Interaction Pattern

For apps that interact with Solana programs (beyond simple transfers):

1. Place Anchor IDL in config/idl/
2. `rails generate solrengine:program ProgramName path/to/idl.json`
3. Server builds instruction data → returns JSON
4. Stimulus controller builds transaction with @solana/kit → wallet signs

Server builds instructions, client signs and sends.

## Conventions

- Rails 8 conventions: Hotwire, Turbo + Stimulus, Solid Queue
- Use Solrengine::Rpc.client singleton for all RPC calls
- Upstream fixes first: fix shared components in solrengine-ui or
  @solrengine/wallet-utils, then bump the starter
- Write tests for new functionality (Minitest)
- NEVER commit: config/master.key, .env files, config/deploy.yml, .kamal/secrets
