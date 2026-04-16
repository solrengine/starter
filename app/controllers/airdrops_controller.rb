class AirdropsController < ApplicationController
  # The AirdropButtonComponent shipped by solrengine-ui doesn't include a CSRF
  # token, so we skip forgery protection for this single endpoint. Safe: the
  # only effect is requesting a devnet airdrop for the logged-in user's wallet,
  # which has no cost and no risk of state corruption.
  skip_forgery_protection only: :create

  LAMPORTS_PER_SOL = 1_000_000_000

  def create
    address = current_user.wallet_address
    response = Solrengine::Rpc.client.request("requestAirdrop", [address, LAMPORTS_PER_SOL])

    if response["error"]
      message = response.dig("error", "message") || "Unknown RPC error"
      redirect_to dashboard_path,
        alert: "Airdrop failed: #{message}. The public devnet faucet is heavily rate-limited — try https://faucet.solana.com instead."
    else
      redirect_to dashboard_path,
        notice: "Airdrop requested. Balance will update after confirmation."
    end
  rescue => e
    Rails.logger.error("Airdrop failed: #{e.class}: #{e.message}")
    redirect_to dashboard_path, alert: "Airdrop failed: #{e.message}"
  end
end
