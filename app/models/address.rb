class Address < ApplicationRecord
  require "./lib/cep_finder"

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
          neighborhood: result[:neighborhood],
          city_id:      get_city_id(zipcode),
          state_id:     get_state_id(zipcode),
          complement:   result[:complement],
          complement2:  result[:complement2]
        )
      else
        address.zipcode      = result[:zipcode]
        address.address      = result[:address]
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
