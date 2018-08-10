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

class Account < ApplicationRecord

  # Associations #
  has_one :citizen
  has_one :professional
  has_and_belongs_to_many :service_places
  has_many :blocks
  has_many :notification, dependent: :destroy

  # Validations #
  validates_presence_of :encrypted_password

  # Devise #
  # Include default devise modules. Other availables are:
  # :token_authenticable, :confirmable, 
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  delegate :cpf, to: :citizen

  # DeviseTokenAuth #
  # Include default DeviseTokenAuth methods.
  include DeviseTokenAuth::Concerns::User

  # Overrides devise_token_auth method to add citizen's information
  #
  # @return [Json] account information as json for token validation 
  # response on sign in
  def token_validation_response
    if self.professional.nil?
      response = self.as_json(except: [
        :tokens, :created_at, :updated_at
      ]).merge({
        citizen: self.citizen.complete_info_response
      })
    else
      response = self.as_json(except: [
        :tokens, :created_at, :updated_at
      ]).merge({
        professional: self.professional.basic_info_response,
        citizen: self.citizen.complete_info_response
      })
    end

    professional = Professional.find_by(account_id: self.id)

    if not professional.nil?
      roles = professional.professionals_service_places
        .pluck(:id, :role, :service_place_id)

      roles.each_with_index do |val, index|
        service_place = ServicePlace.find(val[2])
        val[3] = service_place.city_id
        val[4] = service_place.name
        val[5] = service_place.city_hall_id
      end

      roles_response = [].as_json

      roles.each_with_index do |val, index|
        roles_response[index] = {
          'id' => val[0],
          'role' => val[1],
          'city_id' => val[3],
          'city_name' => City.find(val[3]).name,
          'city_hall_id' => val[5],
          'city_hall_name' => CityHall.find(val[5]).name,
          'service_place' => val[4],
          'professional_id' => professional.id
        }.as_json
      end

      response = response.merge({
        roles: roles_response
      })
    end

    return response
  end
end
