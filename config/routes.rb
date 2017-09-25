Rails.application.routes.draw do
  devise_for :accounts

  scope module: 'api' do
    namespace :v1 do
      mount_devise_token_auth_for 'Account', at: 'auth', controllers: {
        registrations: 'api/v1/accounts/registrations',
        sessions:      'api/v1/accounts/sessions'
      }

      get "accounts/self" => "accounts#index"

      resources :citizens do
        resources :dependants
        member do
          get 'picture'
          get 'schedule_options'
        end
      end

      resources :schedules do
        member do
          put 'confirm'
          get 'confirmation'
        end
      end

      resources :city_halls
      resources :occupations
      resources :professionals
      resources :sectors
      resources :service_places
      resources :service_types
      resources :shifts
      resources :solicitations

      post "validate_cep" => "cep#validate"
      get "forms/schedule_history" => "forms#schedule_history"
    end
  end
end
