class DashboardController < ApplicationController
  def show
    @balance_sol = fetch_balance
    @nfts = fetch_nfts
  end

  private

  def fetch_balance
    solana_client.get_balance(current_user.wallet_address) || 0.0
  rescue => e
    Rails.logger.error("Balance fetch failed: #{e.class}: #{e.message}")
    0.0
  end

  def fetch_nfts
    Solrengine::Tokens::Portfolio.new(current_user.wallet_address).nfts
  rescue => e
    # DAS needs a Helius-style RPC; degrade gracefully on public endpoints
    Rails.logger.error("NFT fetch failed: #{e.class}: #{e.message}")
    []
  end
end
