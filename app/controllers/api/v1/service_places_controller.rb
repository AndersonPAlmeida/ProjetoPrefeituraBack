# This file is part of Agendador.
#
# Agendador is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Agendador is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Agendador.  If not, see <https://www.gnu.org/licenses/>.

module Api::V1
  class ServicePlacesController < ApplicationController
    include Authenticable

    before_action :set_service_place, only: [:show, :update, :destroy]

    # GET /service_places
    def index
      if params[:service_type_id].nil? or params[:schedule].nil? or params[:schedule] != 'true'
        @service_places = policy_scope(ServicePlace.filter(params[:q], params[:page],
          Professional.get_permission(current_user[1])))

      else 
        # if service_type is specified, then request should return 
        # service_places from the given service_type
        service_type = ServiceType.find(params[:service_type_id])

        # show schedules from every service_place from the given service_type
        # (used in scheduling process)
        @service_places = ServicePlace.get_schedule_response(service_type)
          .to_json

        render json: @service_places
        return
      end

      if @service_places.nil?
        render json: {
          errors: ["You don't have the permission to view service places."]
        }, status: 403
      else
        response = Hash.new
        response[:num_entries] = @service_places.total_count
        response[:entries] = @service_places.index_response

        render json: response.to_json
      end
    end


    # GET /service_places/1
    def show
      if @service_place.nil?
        render json: {
          errors: ["Service place #{params[:id]} does not exist."]
        }, status: 404
      else
        begin
          authorize @service_place, :show?
        rescue
          render json: {
            errors: ["You're not allowed to view this service place."]
          }, status: 403
          return
        end

        render json: @service_place.complete_info_response
      end
    end

    
    # POST /service_places
    def create
      # Grab service_types ids to insert later
      service_types_ids = service_place_params[:service_types]
      params[:service_place].delete(:service_types)

      @service_place = ServicePlace.new(service_place_params)

      begin
        authorize @service_place, :create?
      rescue
        render json: {
          errors: ["You're not allowed to create this service place."]
        }, status: 403
        return
      end

      # Get provided service_types, but only local ones. Non-local
      # should not be displayed as an option in the front-end, but this
      # insures that it isn't possible anyway.
      service_types = ServiceType.where(id: service_types_ids)
        .local_city_hall(service_place_params[:city_hall_id])

      # Insert service_types in the new service_place
      @service_place.service_types = service_types

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
        # Grab service_types ids to insert later
        service_types_ids = service_place_params[:service_types]
        params[:service_place].delete(:service_types)

        @service_place.assign_attributes(service_place_params)

        begin
          authorize @service_place, :update?
        rescue
          render json: {
            errors: ["You're not allowed to update this service place."]
          }, status: 403
          return
        end

        # Get provided service_types, but only local ones. Non-local
        # should not be displayed as an option in the front-end, but this
        # insures that it isn't possible anyway.
        service_types = ServiceType.where(id: service_types_ids)
          .local_city_hall(service_place_params[:city_hall_id])

        # Insert service_types in the new service_place
        @service_place.service_types = service_types

        if @service_place.save
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
        :active,
        :address_complement,
        :address_number,
        :cep,
        :city_hall_id,
        :email,
        :name,
        :phone1,
        :phone2,
        :url,
        :service_types => []
      )
    end
  end
end
