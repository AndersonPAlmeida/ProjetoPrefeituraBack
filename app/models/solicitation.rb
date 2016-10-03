class Solicitation < ApplicationRecord

  # Associations #
  belongs_to :city

  # Validations #
  validates_presence_of   :cpf, :name, :email, :phone, :cep
  validates_uniqueness_of :cpf, scope: :city_id
  validates               :cpf, cpf: true
end
