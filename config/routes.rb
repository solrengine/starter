Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Lookbook component browser — mounted in all environments so visitors to
  # the deployed starter can see every solrengine-ui component in action.
  mount Lookbook::Engine, at: "/lookbook"

  # Authentication
  get  "login",       to: "sessions#new",     as: :login
  get  "auth/nonce",  to: "sessions#nonce",   as: :auth_nonce
  post "auth/verify", to: "sessions#create",  as: :auth_verify
  delete "logout",    to: "sessions#destroy",  as: :logout

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
