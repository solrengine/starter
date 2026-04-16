class TokensController < ApplicationController
  def index
    @tokens = fetch_tokens
  end

  private

  def fetch_tokens
    portfolio = Solrengine::Tokens::Portfolio.new(current_user.wallet_address)
    portfolio.tokens.map do |t|
      {
        symbol: t[:symbol],
        name: t[:name],
        balance: t[:ui_amount_string],
        icon_uri: t[:icon],
        usd_value: t[:usd_value]
      }
    end
  rescue => e
    Rails.logger.error("Token fetch failed: #{e.class}: #{e.message}")
    []
  end
end
