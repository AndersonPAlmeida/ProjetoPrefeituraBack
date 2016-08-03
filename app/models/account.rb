class Account < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User

  has_one :citizen

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         authentication_keys: [:cpf]

  def cpf
    self.citizen.cpf
  end
end
