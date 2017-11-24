class Occupation < ApplicationRecord

  # Associations #
  has_many   :professionals
  belongs_to :city_hall

  # Validations #
  validates_presence_of  :name, :description, :city_hall_id
  validates_inclusion_of :active, in: [true,false]
  validates_format_of    :name, with: /\A[^0-9`!@#\$%\^&*+_=]+\z/

  scope :all_active, -> { 
    where(active: true) 
  }

  scope :local_city_hall, -> (city_hall_id) { 
    where(city_hall_id: city_hall_id)
  }
end
