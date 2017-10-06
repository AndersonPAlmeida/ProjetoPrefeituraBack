module Searchable
  extend ActiveSupport::Concern

  included do

    # @params params [ActionController::Parameters] Parameters for searching
    # @params npage [String] number of page to be returned
    # @return [Array] result of search given the parameters and page
    def self.search(params, npage)
      return self.ransack(params).result.page(npage).per(20)
    end

    # @params params [ActionController::Parameters] Unfiltered parameters
    # @params filter [Hash] Translation table
    # @params sortable [Array] Array of possible values for key "s" (sorted)
    # @return [Hash] filtered and translated parameters
    def self.filter_search_params(params, filter, sortable)

      # If nil gets returned then the search result will be every 
      # record (no filter params)
      if params.nil?
        return nil
      end

      # Removes sorting param if it doesn't match the available options
      if sortable.nil? or (params.key?("s") and 
          not sortable.include?(params["s"].split(' ')[0]))
        params.delete("s")
      end

      # Translates permited parameters and remove unpermitted
      return params.permit(filter.keys).to_h.reduce({}) do |hash, (k, v)|
        hash.merge(filter[k] => v) if filter.key?(k)
      end
    end
  end
end
