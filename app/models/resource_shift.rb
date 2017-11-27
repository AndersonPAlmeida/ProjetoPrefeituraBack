class ResourceShift < ApplicationRecord
    include Searchable

    has_many :resource_booking
    has_one :professionals_service_place
    has_one :resource
    has_many :resource_shift

    validates_presence_of :resource_id,
                          :professional_responsible_id,
                          :execution_start_time,
                          :execution_end_time,
                          :borrowed,
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


        sortable = ["resource_id",
                    "professional_responsible_id",
                    "next_shift_id",
                    "active",
                    "borrowed",
                    "execution_start_time",
                    "execution_end_time",
                    "notes",
                    "created_at",
                    "updated_at"
                    ]
        filter = {
                    "resource_id" => "resource_id_eq",
                    "professional_responsible_id" => "professional_responsible_id_eq",
                    "borrowed" => "borrowed_eq",
                    "notes" => "notes_cont",
                    "s" => "s" 
                 }

        return filter_search_params(params, filter, sortable) 
    end

end
