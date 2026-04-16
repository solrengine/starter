class DashboardController < ApplicationController
  def show
    @balance_sol = fetch_balance
  end

  private

  def fetch_balance
    solana_client.get_balance(current_user.wallet_address) || 0.0
  rescue => e
    Rails.logger.error("Balance fetch failed: #{e.class}: #{e.message}")
    0.0
  end
end
