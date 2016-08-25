class ServicePlace < ApplicationRecord
  # Associations #
  has_many :professionals
  has_many :accounts

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

  # @return list of service place's columns
  def self.keys
    return [ :active, :address_number, :address_street,
	     :name, :neighborhood, :address_complement,
	     :cep, :email, :phone1, :phone2, :url ] 

  # @return all active service places
  def self.all_active
    ServicePlace.where(active: true)
  end
end
