module Api::V1
  class FormsController < ApplicationController
    include Authenticable

    # GET /forms/schedule_history
    def schedule_history
      response = Hash.new

      sectors = Sector.form_data(current_user)
      sector_ids = sectors.map { |row| row["id"] }

      service_types = ServiceType.form_data(current_user, sector_ids)
      service_type_ids = service_types.map { |row| row["id"] }

      service_places = ServicePlace.form_data(current_user, service_type_ids)

      situations = Situation.form_data()

      response[:sectors]       = sectors
      response[:service_type]  = service_types 
      response[:service_place] = service_places
      response[:situation] = situations

      render json: response.as_json
    end
  end
end
