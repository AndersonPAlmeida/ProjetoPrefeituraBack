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
end
