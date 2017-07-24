module Api::V1
  class ServicePlacesController < ApplicationController
    include Authenticable

    before_action :set_service_place, only: [:show, :update, :destroy]

    # GET /service_places
    def index
      if params[:service_type_id].nil?
        @service_places = ServicePlace.all
      else
        service_type = ServiceType.find(params[:service_type_id])

        if params[:schedule].nil?
          @service_places = ServicePlace.where(active: true)
                                        .find(service_type.service_place_ids)
        elsif params[:schedule] == 'true'
          service_places = ServicePlace.where(active: true)
                                       .find(service_type.service_place_ids)

          service_places_response = service_places.as_json(only: [:id, :name],
                                                          include: {city_hall: {only: :schedule_period}})

          for i in service_places_response
            i["schedule_period"] = i["city_hall"]["schedule_period"]
            i.delete("city_hall")
            i["schedules"] = Schedule.where(shifts: {service_type_id: params[:service_type_id]})
                                     .includes(:shift)
                                     .where(service_place_id: i["id"])
                                     .where(situation_id: Situation.disponivel)
                                     .as_json(only: [
                                       :id, 
                                       :service_start_time, 
                                       :service_end_time
                                     ])
          end

          @service_places = service_places_response
        end
      end

      render json: @service_places
    end

    # GET /service_places/1
    def show
      if @service_place.nil?
        render json: {
          errors: ["Service place #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @service_place
      end
    end

    # POST /service_places
    def create
      @service_place = ServicePlace.new(service_place_params)

      if @service_place.save
        render json: @service_place, status: :created 
      else
        render json: @service_place.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /service_places/1
    def update
      if @service_place.nil?
        render json: {
          errors: ["Service place #{params[:id]} does not exist."]
        }, status: 404
      else
        if @service_place.update(service_place_params)
          render json: @service_place
        else
          render json: @service_place.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /service_places/1
    def destroy
      if @service_place.nil?
        render json: {
          errors: ["Service place #{params[:id]} does not exist."]
        }, status: 404
      else
        @service_place.active = false
        @service_place.save
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_service_place
      begin
        @service_place = ServicePlace.find(params[:id])
      rescue
        @service_place = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def service_place_params
      params.require(:service_place).permit(
        :id,
        :active,
        :address_complement,
        :address_number,
        :address_street,
        :cep,
        :city_hall_id,
        :email,
        :name,
        :neighborhood,
        :phone1,
        :phone2,
        :url
      )
    end
  end
end
