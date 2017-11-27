class ResourceType < ApplicationRecord
    include Searchable
    
    has_many :resource
    belongs_to :city_hall


    validates_presence_of :city_hall_id,
                          :name,
                          :mobile


    def self.filter(params, npage, permission)
        return search(search_params(params, permission), npage)
    end

    private

    # Translates incoming search parameters to ransack patterns
    # @params params [ActionController::Parameters] Parameters for searching
    # @params permission [String] Permission of current user
    # @return [Hash] filtered and translated parameters
    def self.search_params(params, permission)

        case permission
        when "adm_c3sl"
            # sortable = ["name", "description", "active", "schedules_by_sector", "city_hall_name"]
            sortable = ["city_hall_id","name", "active", "mobile", "description"]
            filter = {"name" => "name_cont", "description" => "description_cont", 
                    "city_hall_id" => "city_hall_id_eq", "s" => "s"}

        when "adm_prefeitura"
            sortable = ["name", "description", "active", "mobile"]
            filter = {"name" => "name_cont", "description" => "description_cont", "s" => "s"}

        when "adm_local"
            sortable = ["name", "description", "active", "mobile"]
            filter = {"name" => "name_cont", "description" => "description_cont", "s" => "s"}
        end

        return filter_search_params(params, filter, sortable) 
    end
end
