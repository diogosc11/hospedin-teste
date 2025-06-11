Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :clients
      resources :products
      resources :payments

      post 'webhooks/pagarme', to: 'webhooks#pagarme'
    end
  end
end
