class Situation < ApplicationRecord
  
  # Associations #
    has_many :schedules

  # Validations #
    validates_presence_of :description

  # @return list of shift's columns
  def self.keys
    return [
      :description
    ]
  end
end
