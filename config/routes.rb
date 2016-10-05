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
      resources :professionals
      resources :sectors
      resources :service_places
      resources :solicitations
      post "validate_cep" => "cep#validate"
    end
  end
end
