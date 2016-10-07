class Situation < ApplicationRecord
  
  # Associations #
    has_many :schedules

  # @return list of shift's columns
  def self.keys
    return [
      :description
    ]
  end
end
