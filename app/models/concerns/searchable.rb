module Searchable
  extend ActiveSupport::Concern

  included do

    # @params params [ActionController::Parameters] Parameters for searching
    # @params npage [String] number of page to be returned
    # @return [Array] result of search given the parameters and page
    def self.search_function(params, npage)
      return self.ransack(params).result.page(npage).per(20)
    end

    # @params params [ActionController::Parameters] Unfiltered parameters
    # @params filter [Hash] Translation table
    # @params sortable [Array] Array of possible values for key "s" (sorted)
    # @return [Hash] filtered and translated parameters
    def self.filter_search_params(params, filter, sortable)
      if params.nil?
        return nil
      end

      if sortable.nil? or (params.key?("s") and not sortable.include?(params["s"]))
        params.delete("s")
      end

      # Translates permited parameters and remove unpermitted
      return params.permit(filter.keys).to_h.reduce({}) do |hash, (k,v)|
        hash.merge(filter[k] => v) if filter.key?(k)
      end
    end
  end
end
