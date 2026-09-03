Rails.application.routes.draw do
  root "runs#index"

  get "sign_in", to: "sessions#new", as: :new_session
  resource :session, only: %i[create destroy]
  get "runs/:id/summary", to: "runs#summary", as: :run_summary
  resources :runs, only: %i[index new create show] do
    resources :cards, only: [] do
      resource :advancement, only: %i[create], module: :cards
    end
    resources :agent_messages, only: %i[create]
    resources :cost_entries, only: %i[create]
    resources :failures, only: [] do
      resource :resolution, only: %i[create], module: :failures
      resource :reassignment, only: %i[create], module: :failures
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
