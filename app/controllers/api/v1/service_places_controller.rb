module Api::V1
  class ServicePlacesController < ApplicationController
    include Authenticable

    before_action :set_service_place, only: [:show, :update, :destroy]

    # GET /service_places
    def index
      if params[:service_type_id].nil?
        @service_places = ServicePlace.all
      else 
        # if service_type is specified, then request should return 
        # service_places from the given service_type
        service_type = ServiceType.find(params[:service_type_id])

        # show only service_place info
        if params[:schedule].nil? or params[:schedule] != 'true'

          @service_places = ServicePlace.where(active: true)
            .find(service_type.service_place_ids)

        elsif params[:schedule] == 'true'

          # show schedules from every service_place from the given service_type
          # (used in schedule action)
          @service_places = ServicePlace.get_schedule_response(service_type).to_json
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
