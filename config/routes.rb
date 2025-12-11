# config/routes.rb (Update)

Rails.application.routes.draw do
  # Set the home page to the Dispute Review Queue
  root "disputes#index"

  # Authentication Routes
  get "sign_in", to: "sessions#new"
  post "sessions", to: "sessions#create"
  delete "sign_out", to: "sessions#destroy"

  # Core Dispute Routes
  resources :disputes, only: [ :index, :show, :update ] # Handled triage and transitions

  # Webhook Route
  post "/webhooks/disputes", to: "webhooks#disputes", as: :disputes_webhook

  # Reporting Routes (non-namespaced controller)
  get "/reports/daily_volume", to: "reports#daily_dispute_volume", as: :reports_daily_volume
  get "/reports/time_to_decision", to: "reports#time_to_decision", as: :reports_time_to_decision
end
