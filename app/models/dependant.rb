class Dependant < ApplicationRecord

  # Associations #
  belongs_to :citizen
  has_many   :blocks

  # @return all active dependants
  def self.all_active
    Dependant.where(active: true)
  end

  # Used when the city, state and address are necessary (show)
  #
  # @return [Json] detailed dependant's data
  def complete_info_response
    return self.as_json(only: [:id, :active, :deactivated])
      .merge({
        citizen: self.citizen.complete_info_response
      })
  end
end
