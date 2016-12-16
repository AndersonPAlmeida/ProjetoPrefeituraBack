class CityHall < ApplicationRecord

  # Associations #
  has_many :service_places
  belongs_to :city

  # Validations #
  validates_presence_of     :name,
    :cep,
    :neighborhood,
    :address_street,
    :address_number,
    :city_id,
    :phone1,
    :schedule_period,
    :previous_notice
  validates_presence_of     :block_text, if: :citizen_access_blocked?

  validates_uniqueness_of   :city_id

  validates_inclusion_of    :active, in: [true, false]
  validates_inclusion_of    :citizen_access,
    :citizen_register, in: [true, false]

  validates_numericality_of :schedule_period,
    :previous_notice, greater_than: 0,
    less_than_or_equal_to: 2000000000


  validates_length_of       :phone1,
    :phone2, maximum: 14
  validates_length_of       :name,
    :neighborhood,
    :address_street,
    :address_complement, maximum: 255
  validates_length_of       :address_number, maximum: 10, allow_blank: true

  def self.all_active
    CityHall.where(active: true)
  end

  private

  # @return [boolean] check if citizen can access city hall
  def citizen_access_blocked?
    !self.citizen_access
  end
end
