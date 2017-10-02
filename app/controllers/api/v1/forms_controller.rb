module Api::V1
  class FormsController < ApplicationController
    include Authenticable

    # GET /forms/schedule_history
    def schedule_history
      response = Hash.new

      # Sectors' ids and names 
      sectors = Sector.form_data(current_user[0])
      sector_ids = sectors.map { |row| row["id"] }

      # Service Types' ids, sector_ids and descriptions
      service_types = ServiceType.form_data(sector_ids)
      service_type_ids = service_types.map { |row| row["id"] }

      # Service Places' ids, service_types' ids and names 
      service_places = ServicePlace.form_data(service_type_ids)

      # Situations' ids and descriptions
      situations = Situation.form_data()

      response[:sectors]       = sectors
      response[:service_type]  = service_types 
      response[:service_place] = service_places
      response[:situation]     = situations

      render json: response.as_json
    end
  end
end
