class Dependant < ApplicationRecord
  include Searchable

  # Associations #
  belongs_to :citizen
  has_many   :blocks

  scope :all_active, -> { 
    where(citizens: { active: true }).includes(:citizen) 
  }


  # Returns json response to index dependants
  # @return [Json] response
  def self.index_response
    dependants_response = []

    self.all.each do |item|
      dependants_response.append(item.citizen.as_json(only: [
        :id, :name, :rg, :cpf, :birth_date
      ]))

      dependants_response[-1]["id"] = item.id
    end

    return dependants_response
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
