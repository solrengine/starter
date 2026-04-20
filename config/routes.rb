Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Lookbook component browser — mounted in all environments so visitors to
  # the deployed starter can see every solrengine-ui component in action.
  mount Lookbook::Engine, at: "/lookbook"

  # SIWS authentication — bundled controller from solrengine-auth.
  mount Solrengine::Auth::Engine => "/auth", as: :solrengine_auth

  # Dashboard
  get "dashboard", to: "dashboard#show", as: :dashboard

  # Tokens
  get "tokens", to: "tokens#index", as: :tokens

  # Send SOL
  get "send", to: "transfers#new", as: :send

  # Devnet airdrop
  post "airdrop", to: "airdrops#create", as: :airdrop

  root "pages#home"
end
