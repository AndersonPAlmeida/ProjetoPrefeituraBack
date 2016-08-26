class State < ApplicationRecord

  # Associations #
  has_many :cities

  # Validations #
  validates_presence_of :ibge_code, :name, :abbreviation
  validates_length_of :ibge_code, :name, minimum: 2, maximum: 255
  validates_length_of :abbreviation, minimum: 2, maximum: 2
end
