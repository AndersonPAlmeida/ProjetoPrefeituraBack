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

      resources :notifications 
      
      resources :resources
      resources :resource_bookings
      resources :resource_types
      resources :resource_shifts
      
      post "validate_cep" => "cep#validate"

      get "forms/schedule_history" => "forms#schedule_history"
      get "forms/create_service_type" => "forms#create_service_type"
      get "forms/create_service_place" => "forms#create_service_place"
      get "forms/create_professional" => "forms#create_professional"
      get "forms/create_shift" => "forms#create_shift"
      get "forms/create_occupation" => "forms#create_occupation"

      get "forms/citizen_index" => "forms#citizen_index"
      get "forms/service_type_index" => "forms#service_type_index"
      get "forms/service_place_index" => "forms#service_place_index"
      get "forms/professional_index" => "forms#professional_index"
      get "forms/shift_index" => "forms#shift_index"
      get "forms/occupation_index" => "forms#occupation_index"
      get "forms/schedule_index" => "forms#schedule_index"

      get "check_create_professional" => "professionals#check_create_professional"
      get "resource_details/:id" => "resources#details"
      get "resource_more_info" => "resources#all_details"

      get "resource_shift_professional_responsible/:id" => "resource_shifts#get_professional_resource_shift"

      get "resource_bookings_get_extra_info/" => "resource_bookings#get_extra_info"

    end
  end
end