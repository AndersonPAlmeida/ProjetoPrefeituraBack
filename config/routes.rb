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
      resources :professionals
    end
  end
end
