module Api::V1
  class FormsController < ApplicationController
    include Authenticable

    # GET /forms/schedule_history
    def schedule_history
      citizen = current_user[0]

      # =========================== Sectors ===========================
      sectors = Sector.all_active.local(citizen.city_id)
        .as_json(only: [:name, :id])

      sector_ids = sectors.map { |row| row["id"] }

      # ======================== Service Types ========================
      service_types = ServiceType.where(sector_id: sector_ids, active: true)
        .as_json(only: [:description, :id, :sector_id])

      service_type_ids = service_types.map { |row| row["id"] }

      # ======================= Service Places ========================
      service_types = ServiceType.where(id: service_type_ids)
      ids = service_types.map { |i| i.service_place_ids }.flatten.uniq!

      st_ids = Hash.new

      service_places = ServicePlace.where(id: ids, active: true)
      service_places_resp = service_places.as_json(only: [:name, :id])

      for i in service_places
        st_ids[i.id.to_s] = i.service_type_ids
      end

      for i in service_places_resp 
        i["service_types"] = st_ids[i["id"].to_s]
      end

      service_places_resp.as_json

      # ========================== Situations =========================
      situations = Situation.all.as_json(only: [:id, :description])

      # ========================== Form Data ==========================
      response = Hash.new
      response[:sectors]       = sectors
      response[:service_type]  = service_types 
      response[:service_place] = service_places
      response[:situation]     = situations

      render json: response.as_json 
    end
  end
end
