class Account < ActiveRecord::Base
  has_one :citizen

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  def cpf
    self.citizen.cpf
  end
end
