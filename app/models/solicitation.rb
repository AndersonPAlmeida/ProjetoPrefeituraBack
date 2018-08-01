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

class Solicitation < ApplicationRecord
  include Searchable

  # Associations #
  belongs_to :city, optional: true

  # Validations #
  validates_presence_of   :cpf, :name, :email, :phone, :cep
  validates_uniqueness_of :cpf, scope: :city_id
  validates               :cpf, cpf: true


  before_validation :create_solicitation

  delegate :name, to: :city, prefix: true
  delegate :state_name, to: :city


  # Returns json response to index solicitations
  # @return [Json] response
  def self.index_response
    self.all.as_json(only: [:id, :name, :cep, :phone, :city_id, :email, :sent], 
                    methods: %w(city_name state_name))
  end


  # @return [Json] detailed service_type's data
  def complete_info_response
    city = City.find(self.city_id)
    state = city.state
    address = Address.get_address(self.cep)

    return self.as_json(only: [
       :id, :name, :cpf, :cep, :phone, :email
      ])
      .merge({city: city.as_json(except: [
        :ibge_code, :state_id, :created_at, :updated_at
      ])})
      .merge({state: state.as_json(except: [
        :ibge_code, :created_at, :updated_at
      ])})
      .merge({address: address.as_json(except: [
        :created_at, :updated_at, :state_id, :city_id
      ])})
  end


  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @params permission [String] Permission of current user
  # @return [ActiveRecords] filtered citizens 
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
      sortable = ["name", "cpf", "email", "phone", "city_name", "city_state_name"]
      filter = {"city_id" => "city_id_eq", "sent" => "sent_eq", "s" => "s"}
    end

    return filter_search_params(params, filter, sortable) 
  end


  # Method called when creating a solicitation. It associates 
  # the address to the service place given a cep
  def create_solicitation
    address = Address.get_address(self.cep)
    self.sent = true

    if not address.nil?
      self.city_id = address.city_id

      city = City.find(self.city_id)
      city_hall = CityHall.find_by(city_id: self.city_id)

      if not city_hall.nil?
        self.errors["cep"] << "CityHall already exists for city #{city.name}"
      end
    else
      self.errors["cep"] << "#{self.cep} is invalid."
      return false
    end
  end
end
