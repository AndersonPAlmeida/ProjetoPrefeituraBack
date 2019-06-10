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

class Professional < ApplicationRecord
  include Searchable

  # Associations #
  belongs_to :account
  belongs_to :occupation

  has_one :citizen, through: :account
  has_many :professionals_service_places
  has_many :service_places, through: :professionals_service_places

  
  # Validations #
  validates_presence_of :occupation_id, :account_id


  # Scopes #
  scope :all_active, -> { 
    where(active: true)
  }

  scope :local_city, -> (city_id) { 
    includes(:service_places).where(service_places: {city_id: city_id})
  }

  scope :local_service_place, -> (serv_id) { 
    includes(:service_places).where(service_places: {id: serv_id})
  }


  # Delegations #
  delegate :name, to: :citizen
  delegate :cpf, to: :citizen
  delegate :phone1, to: :citizen
  delegate :email, to: :citizen

  delegate :name, to: :occupation, prefix: true
  delegate :id, to: :service_places, prefix: true


  # Method for getting role from id
  # @param id [Integer/String] permission
  # @return [String] role name
  def self.get_permission(id)
    if /\A\d+\z/.match(id)
      return ProfessionalsServicePlace.find(id).role
    else
      return id
    end
  end


  # Returns json response to index professionals 
  # @return [Json] response
  def self.index_response
    self.all.as_json(only: [:id, :registration, :active], 
      methods: %w(occupation_name cpf name phone1 email roles_names )).uniq
  end


  # Returns partial info json response to index professionals 
  # @return [Json] response
  def self.simple_index_response
    self.all.as_json(only: :id, methods: %w(name)).uniq
  end


  # @return [Json] detailed professional's data
  def complete_info_response
    return self.as_json(only: [:id, :registration, :active, :occupation_id])
      .merge({
        occupation_name: self.occupation.name,
        citizen: self.citizen.partial_info_response,
        service_places: self.professionals_service_places.map { |i| i.info_listing }
      })
  end

  # @return [Json] basic professional's data
  def basic_info_response
    return self.as_json(only: [:id, :registration, :active, :occupation_id], 
                        methods: %w(occupation_name))
  end


  # @return [Array] list of roles
  def roles_ids
    # Array containing every role that the current professional has
    array = self.professionals_service_places.pluck(:id)
    return array
  end


  # @return [Array] list of roles' names
  def roles_names
    # Array containing every role that the current professional has
    array = self.professionals_service_places.pluck(:role)
    return array
  end


  # @return [Boolean] professional is adm_c3sl
  def adm_c3sl?
    self.roles_names.map.include?("adm_c3sl")
  end


  # @return [Boolean] professional is adm_prefeitura
  def adm_prefeitura?
    self.roles_names.include?("adm_prefeitura")
  end


  # @return [Boolean] professional is adm_local
  def adm_local?
    self.roles_names.include?("adm_local")
  end


  # @return [Boolean] professional is atendente
  def atendente?
    self.roles_names.include?("atendente_local")
  end


  # @return [Boolean] professional is tecnico
  def tecnico?
    self.roles_names.include?("responsavel_atendimento")
  end


  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @params permission [String] Permission of current user
  # @return [ActiveRecords] filtered sectors
  def self.filter(params, npage, permission)
    return search(search_params(params, permission), npage)
  end


  private

  # Translates incoming search parameters to ransack patterns
  # @params params [ActionController::Parameters] Parameters for searching
  # @params permission [String] Permission of current user
  # @return [Hash] filtered and translated parameters
  def self.search_params(params, permission)
    case permission
    when "adm_c3sl"
      sortable = [
        "citizen_name", 
        "registration", 
        "occupation", 
        "citizen_cpf",           
        "citizen_email", 
        "active"
      ]

      filter = {
        "name"          => "citizen_name_cont", 
        "registration"  => "registration_cont", 
        "cpf"           => "citizen_cpf_eq", 
        "role"          => "professionals_service_places_role_eq", 
        "city_hall"     => "service_places_city_hall_id_eq",
        "occupation"    => "occupation_id_eq",
        "service_place" => "service_places_id_eq",
        "active"        => "active_eq",
        "s"             => "s"
      }

    when "adm_prefeitura"
      sortable = [
        "citizen_name", 
        "registration", 
        "occupation", 
        "citizen_cpf",          
        "citizen_email", 
        "active"
      ]

      filter = {
        "name"          => "citizen_name_cont", 
        "registration"  => "registration_cont", 
        "cpf"           => "citizen_cpf_eq", 
        "role"          => "professionals_service_places_role_eq", 
        "city_hall"     => "service_places_city_hall_id_eq",
        "occupation"    => "occupation_id_eq",
        "service_place" => "service_places_id_eq",
        "active"        => "active_eq",
        "s"             => "s"
      }
      
    when "adm_local"
      sortable = [
        "citizen_name", 
        "registration", 
        "occupation", 
        "citizen_cpf",          
        "citizen_email", 
        "active"
      ]

      filter = {
        "name"          => "citizen_name_cont", 
        "registration"  => "registration_cont", 
        "cpf"           => "citizen_cpf_eq", 
        "role"          => "professionals_service_places_role_eq", 
        "city_hall"     => "service_places_city_hall_id_eq",
        "occupation"    => "occupation_id_eq",
        "service_place" => "service_places_id_eq",
        "active"        => "active_eq",
        "s"             => "s"
      }
    end

    return filter_search_params(params, filter, sortable) 
  end
end
