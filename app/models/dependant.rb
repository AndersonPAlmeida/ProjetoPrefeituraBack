class Dependant < ApplicationRecord
  include Searchable

  # Associations #
  belongs_to :citizen
  has_many   :blocks

  # @return all active dependants
  def self.all_active
    Dependant.where(citizens: { active: true }).includes(:citizen)
  end

  # Used when the city, state and address are necessary (show)
  #
  # @return [Json] detailed dependant's data
  def complete_info_response
    return self.as_json(only: [:id, :deactivated])
      .merge({
        citizen: self.citizen.complete_info_response
      })
  end
  
  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @return [ActiveRecords] filtered citizens 
  def self.filter(params, npage)
    return search(search_params(params), npage)
  end

  private

  # Translates incoming search parameters to ransack patterns
  # @params params [ActionController::Parameters] Parameters for searching
  # @return [Hash] filtered and translated parameters
  def self.search_params(params)
    sortable = ["citizen_name", "citizen_cpf", "citizen_birth_date"]
    filter = {"name" => "citizen_name_cont", "s" => "s"}

    return filter_search_params(params, filter, sortable) 
  end
end
