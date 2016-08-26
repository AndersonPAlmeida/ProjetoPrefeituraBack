class City < ApplicationRecord

  # Associations #
  has_many :city_halls
  has_many :citizens 
  belongs_to :state

  # Validations #
  validates_presence_of :ibge_code, :name, :state_id
  validates_numericality_of :state_id, only_integer: true
  validates_length_of :ibge_code, :name, minimum: 2, maximum: 255
end