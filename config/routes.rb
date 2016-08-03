Rails.application.routes.draw do
  resources :citizens
  mount_devise_token_auth_for 'Account', at: 'auth'
  scope module: 'api' do
    namespace :v1 do
      
    end
  end
end
