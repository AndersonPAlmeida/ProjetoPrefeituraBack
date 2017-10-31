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
      service_types_resp = ServiceType.where(sector_id: sector_ids, active: true)
        .as_json(only: [:description, :id, :sector_id])


      # ======================= Service Places ========================
      service_type_ids = service_types_resp.map { |row| row["id"] }

      service_types = ServiceType.where(id: service_type_ids)
      ids = service_types.map { |i| i.service_place_ids }.flatten.uniq

      st_ids = Hash.new

      service_places = ServicePlace.where(id: ids, active: true)
      service_places_resp = service_places.as_json(only: [:name, :id])

      for i in service_places
        st_ids[i.id.to_s] = i.service_type_ids
      end

      for i in service_places_resp 
        i["service_types"] = st_ids[i["id"].to_s]
      end


      # ========================== Situations =========================
      situations = Situation.all.as_json(only: [:id, :description])


      # ========================== Form Data ==========================
      response = Hash.new
      response[:sectors]       = sectors
      response[:service_type]  = service_types_resp
      response[:service_place] = service_places_resp
      response[:situation]     = situations

      render json: response.as_json 
    end

    # GET /forms/citizen_index
    def citizen_index
      citizen = current_user[0]
      permission = Professional.get_permission(current_user[1])
      response = Hash.new

      case permission
      when "adm_c3sl"
        city_halls = CityHall.all_active
        response[:city_halls] = city_halls.as_json(only: [:id, :name, :city_id])

      else
        render json: {
          errors: ["You're not allowed to view this form."]
        }, status: 403
        return
      end

      render json: response.as_json
    end

    # GET /forms/service_type_index
    def service_type_index
      citizen = current_user[0]
      permission = Professional.get_permission(current_user[1])
      response = Hash.new

      case permission
      when "adm_c3sl"
        city_halls = CityHall.all_active
        response[:city_halls] = city_halls.as_json(only: [:id, :name, :city_id])

      else
        render json: {
          errors: ["You're not allowed to view this form."]
        }, status: 403
        return
      end

      render json: response.as_json
    end

    # GET /forms/sector_index
    def sector_index
      citizen = current_user[0]
      permission = Professional.get_permission(current_user[1])
      response = Hash.new

      case permission
      when "adm_c3sl"
        city_halls = CityHall.all_active
        response[:city_halls] = city_halls.as_json(only: [:id, :name, :city_id])

      else
        render json: {
          errors: ["You're not allowed to view this form."]
        }, status: 403
        return
      end

      render json: response.as_json
    end

    # GET /forms/create_service_type
    def create_service_type
      citizen = current_user[0]
      permission = Professional.get_permission(current_user[1])

      response = Hash.new

      case permission
      when "adm_c3sl"
        city_halls = CityHall.all_active
        ids = city_halls.pluck(:id)

        response[:city_halls] = city_halls.as_json(only: [:id, :name])
        response[:sectors] = Sector.where(city_hall_id: ids)
          .as_json(only: [:id, :name, :city_hall_id])

      when "adm_prefeitura"
        city_hall_id = citizen.professional.professionals_service_places
          .find(current_user[1]).service_place.city_hall.id

        response[:sectors] = Sector.where(city_hall_id: city_hall_id)
          .as_json(only: [:id, :name])

      else
        render json: {
          errors: ["You're not allowed to view this form."]
        }, status: 403
        return
      end

      render json: response.as_json
    end

    # GET /forms/service_place_index
    def service_place_index
      citizen = current_user[0]
      permission = Professional.get_permission(current_user[1])
      response = Hash.new

      case permission
      when "adm_c3sl"
        city_halls = CityHall.all_active
        response[:city_halls] = city_halls.as_json(only: [:id, :name, :city_id])

      else
        render json: {
          errors: ["You're not allowed to view this form."]
        }, status: 403
        return
      end

      render json: response.as_json
    end

    # GET /forms/create_service_place
    def create_service_place
      citizen = current_user[0]
      permission = Professional.get_permission(current_user[1])

      response = Hash.new
      result, status = Address.get_cep_response(params[:cep])

      if not status.nil?
        render json: result, status: status
        return
      end

      case permission
      when "adm_c3sl"
        city_halls = CityHall.where(city_id: result["city_id"])
          .as_json(only: [:id, :name])

        # Create form must constain options for possible service types
        # to be available to the new service place
        for i in city_halls
          i[:service_types] = ServiceType.local_city_hall(i["id"])
            .as_json(only: [:id, :description])
        end

        result.merge!(city_halls: city_halls)

      when "adm_prefeitura"
        city_hall = citizen.professional.professionals_service_places
          .find(current_user[1]).service_place.city_hall

        if city_hall.city_id == result["city_id"]
          result.merge!(city_halls: [city_hall.as_json(only: [:id, :name])])

          # Create form must constain options for possible service types
          # to be available to the new service place
          result[:city_halls][0][:service_types] = ServiceType
            .local_city_hall(city_hall.id)
            .as_json(only: [:id, :description])

        else
          result.merge!(city_halls: [])
        end


      else
        render json: {
          errors: ["You're not allowed to view this form."]
        }, status: 403
        return
      end

      render json: result.as_json
    end
  end
end
