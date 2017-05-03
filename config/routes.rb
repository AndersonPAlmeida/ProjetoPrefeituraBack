Rails.application.routes.draw do
  devise_for :accounts
  scope module: 'api' do
    namespace :v1 do
      mount_devise_token_auth_for 'Account', at: 'auth', controllers: {
        registrations: 'api/v1/accounts/registrations',
        sessions:      'api/v1/accounts/sessions'
      }

      resources :citizens
      resources :city_halls
      resources :dependants
      resources :occupations
      resources :professionals
      resources :schedules
      resources :sectors
      resources :service_places
      resources :service_types
      resources :shifts
      resources :solicitations

      post "validate_cep" => "cep#validate"
      get "/citizens/:id/picture", to: "citizens#show_picture"
    end
  end
end
