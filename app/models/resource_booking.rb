class ResourceBooking < ApplicationRecord
    include Searchable
  
    belongs_to :resource_shift
    has_many :citizen
    has_many :notification
    has_one :situation
    has_one :service_place

    validates_presence_of :service_place_id, 
                          :resource_shift_id,
                          :situation_id,
                          :citizen_id,
                          :active,
                          :booking_reason,
                          :booking_start_time,
                          :booking_end_time

    def self.filter(params, npage, permission)
        return search(search_params(params, permission), npage)
    end

    private

    # Translates incoming search parameters to ransack patterns
    # @params params [ActionController::Parameters] Parameters for searching
    # @params permission [String] Permission of current user
    # @return [Hash] filtered and translated parameters
    def self.search_params(params, permission)


        sortable = ["service_place_id",
                    "resource_shift_id",
                    "situation_id",
                    "citizen_id",
                    "active",
                    "booking_reason",
                    "booking_start_time",
                    "booking_end_time",
                    "status"
                    ]
        filter = {
                    "service_place_id" => "service_place_id_eq",
                    "resource_shift_id" => "resource_shift_id_eq",
                    "citizen_id" => "citizen_id_eq",
                    "brand" => "brand_cont",
                    "booking_reason" => "booking_reason_cont",
                    "booking_start_time" => "booking_start_time_cont",
                    "booking_end_time" => "booking_end_time_cont", 
                    "status" => "status_cont",
                    "s" => "s" 
                 }

        return filter_search_params(params, filter, sortable) 
    end
end
