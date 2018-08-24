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

class Address < ApplicationRecord
  require "#{Rails.root}/lib/cep_finder"

  has_many :resouce_booking

  # Search for zipcode in database, if not registered, get address from correios
  # api and insert in database to be used as cache
  #
  # @return [Address] address corresponding to zipcode
  def self.get_address(zipcode)
    zipcode = zipcode.gsub(/\D/, '')
    address = Address.find_by(zipcode: zipcode)

    # if not registered in database or registered but too old (180 days)
    if address.nil? or (Date.today - Date.parse(address.updated_at.to_s) > 180)
      result = CepValidator.get_address(zipcode)

      # if cep doesn't exist
      if result.empty?
        return nil
      end

      # if address is not nil then it means that it is older than 180 days
      if address.nil?
        address = Address.new(
          zipcode:      result[:zipcode],
          address:      result[:address],
          number:       result[:number],
          neighborhood: result[:neighborhood],
          city_id:      get_city_id(zipcode),
          state_id:     get_state_id(zipcode),
          complement:   result[:complement],
          complement2:  result[:complement2]
        )
      else
        address.zipcode      = result[:zipcode]
        address.address      = result[:address]
        address.number       = result[:number]
        address.neighborhood = result[:neighborhood]
        address.city_id      = get_city_id(zipcode)
        address.state_id     = get_state_id(zipcode)
        address.complement   = result[:complement]
        address.complement2  = result[:complement2]
        address.updated_at   = Date.today
      end

      address.save!
    end

    return address
  end

  # Validates cep and render an error and return nil if invalid or
  # return the address as a json if valid
  # @param cep [String] cep number
  # @return [Json, Integer] [(address info, nil) | (error message, error status)]
  def self.get_cep_response(cep, only_registered)
    if not CepValidator.valid_format?(cep)
      # return { errors: ["Invalid CEP."] }.to_json, 422
      return { errors: ["CEP inválido!"] }.to_json, 422
    end

    address = Address.get_address(cep)

    # Verify if cep is valid
    if address.nil?
      # return { errors: ["Invalid CEP."] }.to_json, 422
      return { errors: ["CEP inválido!"] }.to_json, 422
    else

      # City may not exist due to tests without setting up cities
      if address[:city_id].nil?
        # return { errors: ["City not registered."] }.to_json, 404
        return { errors: ["Cidade não registrada!"] }.to_json, 404
      end

      city = City.find(address[:city_id])
      state = State.find(city.state_id)

      if not city.nil?
        city_hall = CityHall.where(city_id: city.id)

        # Verify if the city obtained from cep is registered
        if only_registered and city_hall.empty?
          return {
            # errors: ["City not registered."],
            errors: ["Cidade não registrada!"],
            city_name: city.name,
            state_name: state.abbreviation
          }.to_json, 404
        else
          city = City.find(address.city_id).name
          state = State.find(address.state_id).abbreviation

          return address.as_json(except: [:created_at, :updated_at])
            .merge({city_name: city})
            .merge({state_name: state}), nil
        end
      else
        # return { errors: ["City not registered."] }.to_json, 404
        return { errors: ["Cidade não registrada!"] }.to_json, 404
      end
    end
  end

  # @return [Integer] city id corresponding to cep
  def self.get_city_id(cep)
    cep = cep.gsub(/\D/, '')
    if not CepValidator.valid_format?(cep)
      return nil
    end

    address = CepValidator.get_address(cep)
    if address.nil?
      return nil
    end

    state = State.find_by(abbreviation: address[:state])
    if state.nil?
      return nil
    end

    return City.find_by(name: address[:city], state: state.id).id
  end

  # @return [Integer] state id corresponding to cep
  def self.get_state_id(cep)
    cep = cep.gsub(/\D/, '')
    if not CepValidator.valid_format?(cep)
      return nil
    end

    address = CepValidator.get_address(cep)
    if address.nil?
      return nil
    end

    state = State.find_by(abbreviation: address[:state])
    if state.nil?
      return nil
    end

    return state.id
  end
end
