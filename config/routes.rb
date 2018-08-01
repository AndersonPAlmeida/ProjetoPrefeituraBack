# This file is part of Agendador.
#
# Agendador is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Agendador is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Agendador.  If not, see <https://www.gnu.org/licenses/>.

Rails.application.routes.draw do
  devise_for :accounts

#  require 'sidekiq/web'
#  mount Sidekiq::Web => '/sidekiq'

  scope module: 'api' do
    namespace :v1 do
      mount_devise_token_auth_for 'Account', at: 'auth', controllers: {
        registrations: 'api/v1/accounts/registrations',
        sessions:      'api/v1/accounts/sessions',
        passwords:     'api/v1/accounts/passwords'
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

      resources :city_halls do
        member do
          get 'picture'
          post 'picture' => 'city_halls#upload_picture'
        end
      end

      get "citizen_uploads/example_ods" => "citizen_uploads#example_ods"
      get "citizen_uploads/example_xls" => "citizen_uploads#example_xls"

      resources :citizen_uploads

      resources :occupations

      resources :professionals

      resources :sectors
      resources :service_places
      resources :service_types, except: :destroy
      resources :shifts
      resources :solicitations, only: [:create, :index, :show]

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
      get "forms/schedule_per_type_index" => "forms#schedule_per_type_index"
      get "forms/solicitation_index" => "forms#solicitation_index"

      get "schedule_per_type_report" => "schedules#schedule_per_type"
      get "check_create_professional" => "professionals#check_create_professional"
      get "resource_details/:id" => "resources#details"
      get "resource_more_info" => "resources#all_details"

      get "resource_shift_professional_responsible/:id" => "resource_shifts#get_professional_resource_shift"

      get "resource_bookings_get_extra_info/" => "resource_bookings#get_extra_info"

    end
  end
end
