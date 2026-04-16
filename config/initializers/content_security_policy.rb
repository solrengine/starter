# Be sure to restart your server when you modify this file.
#
# Content Security Policy for a Solana dApp:
#  - Scripts and styles load from our own origin (plus per-request nonces for inline).
#  - connect-src must allow the configured Solana RPC endpoints (HTTP + WebSocket) and
#    Jupiter API so the browser can talk to them.
#  - Wallet browser extensions inject content scripts that bypass page CSP, so no
#    additional allowances are needed for Phantom/Backpack/Solflare/etc.

Rails.application.configure do
  config.content_security_policy do |policy|
    # Public Solana RPC endpoints — safe defaults so client-side @solana/kit
    # calls work even when no env override is set. Override by setting the
    # corresponding env vars to your Helius/QuickNode/Triton endpoint.
    rpc_hosts = [
      ENV["SOLANA_RPC_URL"] || "https://api.mainnet-beta.solana.com",
      ENV["SOLANA_RPC_DEVNET_URL"] || "https://api.devnet.solana.com",
      ENV["SOLANA_RPC_TESTNET_URL"] || "https://api.testnet.solana.com"
    ]
    ws_hosts = [
      ENV["SOLANA_WS_URL"] || "wss://api.mainnet-beta.solana.com",
      ENV["SOLANA_WS_DEVNET_URL"] || "wss://api.devnet.solana.com",
      ENV["SOLANA_WS_TESTNET_URL"] || "wss://api.testnet.solana.com"
    ]

    policy.default_src    :self
    policy.font_src       :self, :data
    policy.img_src        :self, :data, :https
    policy.object_src     :none
    policy.script_src     :self
    # Turbo applies inline style attributes (progress bar, preview rendering).
    # CSP nonces and hashes don't apply to style *attributes* (only <style>
    # elements), so we accept :unsafe_inline for styles. Script execution
    # remains nonce-protected, which is what actually matters for XSS.
    policy.style_src      :self, :unsafe_inline
    policy.connect_src    :self, "https://api.jup.ag", *rpc_hosts, *ws_hosts
    policy.frame_ancestors :none
    policy.base_uri       :self
    policy.form_action    :self
  end

  # Generate session nonces for inline scripts. The layout contains a tiny
  # theme-preference script that needs this nonce.
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Start in report-only mode: logs violations in the browser console without breaking
  # the page. Flip to false after verifying nothing essential is blocked.
  config.content_security_policy_report_only = true
end
