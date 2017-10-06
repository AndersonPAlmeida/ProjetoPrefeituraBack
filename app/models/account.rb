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

  delegate :cpf, to: :citizen

  # DeviseTokenAuth #
  # Include default DeviseTokenAuth methods.
  include DeviseTokenAuth::Concerns::User

  # Overrides devise_token_auth method to add citizen's information
  #
  # @return [Json] account information as json for token validation 
  # response on sign in
  def token_validation_response
    response = self.as_json(except: [
      :tokens, :created_at, :updated_at
    ]).merge({
      citizen: self.citizen.complete_info_response
    })

    professional = Professional.find_by(account_id: self.id)

    if not professional.nil?
      roles = professional.professionals_service_places
        .pluck(:id, :role, :service_place_id)
      
      roles.each_with_index do |val, index|
        service_place = ServicePlace.find(val[2])
        val[3] = service_place.city_id
        val[4] = service_place.name
      end

      roles_response = [].as_json

      roles.each_with_index do |val, index|
        roles_response[index] = {
          'id' => val[0],
          'role' => val[1],
          'city_id' => val[3],
          'city_name' => City.find(val[3]).name,
          'service_place' => val[4]
        }.as_json
      end

      response = response.merge({
        roles: roles_response
      })
    end

    return response
  end
end
