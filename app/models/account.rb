class Account < ActiveRecord::Base

  # Associations #
  has_one :citizen
  has_one :professional
  has_and_belongs_to_many :service_places
  has_many :blocks

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
    self.as_json(except: [
      :tokens, :created_at, :updated_at
    ]).merge({citizen: self.citizen.as_json})
  end
end
