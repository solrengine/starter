# SolRengine Starter

A production-ready Solana dApp starter built with **Rails 8** and the [SolRengine](https://solrengine.org) framework. Clone it, connect a wallet, and start building.

## What You Get

- **Wallet authentication** — Sign In With Solana (SIWS) using Phantom, Backpack, Solflare, or any Wallet Standard compatible extension
- **Dashboard** — SOL balance, copy-to-clipboard wallet address, network badge
- **Token list** — SPL holdings with metadata and prices via Jupiter
- **Send SOL** — client-side transfer flow: your wallet signs, no server keypair needed
- **Devnet airdrop** — one-click airdrop button for testing
- **20+ UI components** — Cards, Modals, Badges, Token rows, Transaction status, Notifications, and more from [solrengine-ui](https://rubygems.org/gems/solrengine-ui)
- **Component gallery** — Lookbook at `/lookbook` with live previews of every component
- **Dark mode** — styled for dark by default with full light-mode support ready to enable
- **Production-ready** — Kamal deploy config, CSP, SSL, HSTS, DNS rebinding protection

## Quick Start

```bash
git clone https://github.com/solrengine/starter.git
cd starter
bundle install
yarn install
cp .env.example .env
bin/rails db:prepare
bin/dev
```

Open `http://localhost:3000`, connect your wallet, and you're in.

Browse all components at `http://localhost:3000/lookbook`.

## Environment Variables

Copy `.env.example` to `.env`. All defaults point at public devnet — the only
required value for local dev is `APP_DOMAIN=localhost`.

| Variable | Purpose | Default |
|----------|---------|---------|
| `SOLANA_NETWORK` | Network to use | `devnet` |
| `APP_DOMAIN` | SIWS domain + host authorization | `localhost` |
| `JUPITER_API_KEY` | Token metadata/prices (optional) | — |
| `SOLANA_RPC_URL` | Mainnet RPC override (Helius, QuickNode, etc.) | public endpoint |
| `SOLANA_WS_URL` | Mainnet WebSocket override | public endpoint |

## Project Structure

```
app/
├── controllers/
│   ├── sessions_controller.rb    # SIWS nonce/verify/destroy
│   ├── dashboard_controller.rb   # Balance via RPC
│   ├── tokens_controller.rb      # SPL portfolio via Jupiter
│   ├── transfers_controller.rb   # Renders the Send form
│   └── airdrops_controller.rb    # Devnet airdrop RPC call
├── javascript/controllers/
│   └── index.js                  # Stimulus: WalletController, SendTransactionController
├── views/
│   ├── pages/home.html.erb       # Landing with component showcase
│   ├── dashboard/show.html.erb   # Wallet dashboard
│   ├── tokens/index.html.erb     # Token list
│   └── transfers/new.html.erb    # Send SOL form
└── helpers/
    └── application_helper.rb     # nav_link_to with active state
```

## How It Works

### Wallet Authentication

1. User clicks "Connect Wallet" → `WalletController` discovers wallets via Wallet Standard
2. Wallet signs a SIWS message → `SessionsController` verifies the Ed25519 signature server-side
3. User is identified by `wallet_address` on the `User` model

### Sending SOL

The Send form is **entirely client-side** — no server endpoint:

1. `SendTransactionFormComponent` renders a form with Stimulus `data-controller="send-transaction"`
2. On submit, the controller fetches a blockhash from the RPC, builds a transfer with `@solana/kit`, and asks the wallet to sign and send
3. Success/error status renders inline with an explorer link

### Tailwind + Gem Components

`bin/build-css` resolves the installed `solrengine-ui` gem path via Bundler and passes it to the Tailwind CLI as an `@source` directive. This means Tailwind scans the gem's ERB and Ruby files for class names automatically — no hardcoded paths, no version pinning.

## Customizing

### Add a new page

Standard Rails: `rails generate controller MyPage show`, add a route, wire up the navbar in `app/views/layouts/application.html.erb`.

### Interact with a Solana program

```bash
rails generate solrengine:program MyProgram config/idl/my_program.json
```

This scaffolds account models, instruction services, and a controller from your Anchor IDL. See the [SolRengine Programs gem](https://rubygems.org/gems/solrengine-programs) for details.

### Switch to mainnet

1. Set `SOLANA_NETWORK=mainnet` in `.env`
2. Get a paid RPC from Helius/QuickNode/Triton and set `SOLANA_RPC_URL` / `SOLANA_WS_URL`
3. Set `APP_DOMAIN` to your production domain

### Enable light mode

Uncomment the `ThemeToggleComponent` renders in `app/views/dashboard/show.html.erb`, `app/views/pages/home.html.erb`, and the `javascript_tag` block in `app/views/layouts/application.html.erb`. All views already have `dark:` variants.

## Deploy

This app deploys with [Kamal](https://kamal-deploy.org):

1. Copy `config/deploy.yml.example` to `config/deploy.yml` and fill in your server, domain, and registry
2. Generate Rails credentials: `bin/rails credentials:edit`
3. Set secrets in `.kamal/secrets` (create from the example comments)
4. `bin/kamal deploy`

See [DEPLOY.md](DEPLOY.md) for the full checklist.

## Stack

| Layer | Technology |
|-------|-----------|
| Framework | Rails 8.1, Ruby 3.3.6 |
| Frontend | Hotwire (Turbo + Stimulus), Tailwind CSS 4, esbuild, Propshaft |
| Solana (server) | solrengine-auth, solrengine-rpc, solrengine-programs, solrengine-tokens |
| Solana (client) | @solana/kit, @solrengine/wallet-utils, @wallet-standard/app |
| UI | solrengine-ui (ViewComponent), @solrengine/ui (Stimulus controllers), Lookbook |
| Database | SQLite + Solid Cache + Solid Queue + Solid Cable |
| Deploy | Kamal + Thruster, Let's Encrypt SSL |

## License

MIT
