class Resource < ApplicationRecord    
    include Searchable
    
    belongs_to :service_place
    has_one :resource_type
    has_many :resource_shift

    validates_presence_of :resource_types_id, 
                          :service_place_id,
                          :minimum_schedule_time,
                          :maximum_schedule_time,
                          :active


    def self.filter(params, npage, permission)
        return search(search_params(params, permission), npage)
    end

    private

    # Translates incoming search parameters to ransack patterns
    # @params params [ActionController::Parameters] Parameters for searching
    # @params permission [String] Permission of current user
    # @return [Hash] filtered and translated parameters
    def self.search_params(params, permission)


        sortable = ["resource_types_id",
                    "service_place_id",
                    "professional_responsible_id",
                    "minimum_schedule_time",
                    "maximum_schedule_time",
                    "active",
                    "brand",
                    "model",
                    "label",
                    "note"
                    ]
        filter = {
                    "service_place_id" => "service_place_id_eq",
                    "professional_responsible_id" => "professional_responsible_id_eq",
                    "brand" => "brand_cont",
                    "model" => "model_cont",
                    "label" => "label_cont",
                    "note" => "note_cont", 
                    "s" => "s" 
                    }

        return filter_search_params(params, filter, sortable) 
    end

end
