Rails.application.routes.draw do
  scope module: 'api' do
    namespace :v1 do
      devise_for :citizens
      mount_devise_token_auth_for 'Account', at: 'auth', controllers: {
        registrations: 'api/v1/accounts/registrations',
        sessions:      'api/v1/accounts/sessions'
      }
      resources :citizens
    end
  end
end
