class Dependant < ApplicationRecord

  # Associations #
  belongs_to :citizen
  has_many   :blocks

  # @return list of dependant's columns
  def self.keys
    return [
      :active,
      :deactivated
    ]
  end

  # @return all active dependants
  def self.all_active
    Dependant.where(active: true)
  end
end
