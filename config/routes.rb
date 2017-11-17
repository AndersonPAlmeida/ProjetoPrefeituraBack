Rails.application.routes.draw do
  devise_for :accounts

  scope module: 'api' do
    namespace :v1 do
      mount_devise_token_auth_for 'Account', at: 'auth', controllers: {
        registrations: 'api/v1/accounts/registrations',
        sessions:      'api/v1/accounts/sessions'
      }

      get "accounts/self" => "accounts#index"

      get "citizens/schedule_options" => "citizens#schedule_options"

      resources :citizens do
        resources :dependants
        member do
          get 'picture'
      #    get 'schedule_options'
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
      resources :service_types, except: :destroy
      resources :shifts
      resources :solicitations

      post "validate_cep" => "cep#validate"

      get "forms/schedule_history" => "forms#schedule_history"
      get "forms/create_service_type" => "forms#create_service_type"
      get "forms/create_service_place" => "forms#create_service_place"
      get "forms/create_professional" => "forms#create_professional"

      get "forms/citizen_index" => "forms#citizen_index"
      get "forms/service_type_index" => "forms#service_type_index"
      get "forms/service_place_index" => "forms#service_place_index"

      get "check_create_professional" => "professionals#check_create_professional"
    end
  end
end
