class Account < ApplicationRecord

  # Associations #
  has_one :citizen
  has_one :professional
  has_and_belongs_to_many :service_places
  has_many :blocks

  # Validations #
  validates_presence_of :encrypted_password

  # Devise #
  # Include default devise modules. Other availables are:
  # :token_authenticable, :confirmable, 
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # DeviseTokenAuth #
  # Include default DeviseTokenAuth methods.
  include DeviseTokenAuth::Concerns::User

  # @return [String] citizen's cpf
  def cpf
    self.citizen.cpf
  end

  # Overrides devise_token_auth method to add citizen's information
  #
  # @return [Json] account information as json for token validation 
  # response on sign in
  def token_validation_response
    city = citizen.city
    state = city.state

    address = Address.get_address(self.citizen.cep)
    professional = Professional.find_by(account_id: self.id)

    response = self.as_json(except: [
      :tokens, :created_at, :updated_at
    ]).merge({
      citizen: self.citizen.as_json(except: [:city_id, :created_at, :updated_at])
        .merge({city: city.as_json(except: [
          :ibge_code, :state_id, :created_at, :updated_at
        ])})
        .merge({state: state.as_json(except: [
          :ibge_code, :created_at, :updated_at
        ])})
        .merge({address: address.as_json(except: [
          :created_at, :updated_at, :state_id, :city_id
        ])})
    })

    if not professional.nil?
      roles = professional.professionals_service_places
        .pluck(:role, :service_place_id)
      
      roles_response = [].as_json

      roles.each_with_index do |val, index|
        service_place = ServicePlace.find(val[1])
        val[2] = service_place.city_id
        val[3] = service_place.name
      end

      roles.each_with_index do |val, index|
        roles_response[index] = {
          'role' => val[0],
          'city_id' => val[2],
          'city_name' => City.find(val[2]).name,
          'service_place' => val[3]
        }.as_json
      end

      response = response.merge({
        roles: roles_response
      })
    end

    return response
  end
end
