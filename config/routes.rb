Rails.application.routes.draw do
  root "runs#index"

  get "sign_in", to: "sessions#new", as: :new_session
  resource :session, only: %i[create destroy]
  resources :runs, only: %i[index new create]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
