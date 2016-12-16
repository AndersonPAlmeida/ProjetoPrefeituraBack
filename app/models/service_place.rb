class ServicePlace < ApplicationRecord

  # Associations #
  belongs_to :city_hall
  has_many :professionals_service_places
  has_many :professionals, through: :professionals_service_places
  has_and_belongs_to_many :accounts
  has_and_belongs_to_many :service_types

  # Validations #
  validates_presence_of :address_number
  validates_presence_of :address_street
  validates_presence_of :name
  validates_presence_of :neighborhood

  validates_length_of   :name, maximum: 255
  validates_length_of   :address_number, within: 0..10,
    allow_blank: true

  validates_numericality_of :address_number,
    only_integer: true,
    allow_blank: true

  # @return all active service places
  def self.all_active
    ServicePlace.where(active: true)
  end
end
