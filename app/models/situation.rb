class Situation < ApplicationRecord
  
  # Associations #
    has_many :schedules

  # Validations #
    validates_presence_of :description
end
