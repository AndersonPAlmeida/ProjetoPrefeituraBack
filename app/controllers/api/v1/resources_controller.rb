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
  class ResourcesController < ApplicationController
    include Authenticable

    before_action :set_resource, only: [:show, :update, :destroy]

    def all_details
      citizen = current_user.first

      professional = citizen.professional

      service_place = professional.professionals_service_places.find(
        params[:permission]).service_place

      city_hall_id = service_place.city_hall_id

      @resources = policy_scope(Resource.filter(params[:q], params[:page],
        Professional.get_permission(current_user[1])))

      if @resources.nil?
        render json: {
          # errors: ["You don't have the permission to view resources."]
          errors: ["Você não tem permissão para listar recursos!"]
        }, status: 403
      else
        resources_local = {
          service_place_id: [],
          resource_types_id: []
        }

        @resources.each do |r|
          resources_local[:service_place_id] << r.service_place_id
          resources_local[:resource_types_id] << r.resource_types_id
        end

        service_place = ServicePlace.where(
          id: resources_local[:service_place_id]).to_a
        resource_type = ResourceType.where(
          id: resources_local[:resource_types_id]).to_a

        detailed_info = {
          resource: @resources,
          service_place: service_place,
          resource_type: resource_type
        }

        render json: detailed_info
      end
    end


    #GET /resource_details
    def details
      @resources = Resource.where(id: params[:id]).first

      professional_name = Citizen.where(
                            account_id:Account.where(
                                  id:Professional.where(
                                      id:@resources.professional_responsible_id
                                  ).first.id
                            ).first.id
                          ).first.name

      service_place = ServicePlace.where(
        id: @resources.service_place_id).first
      resource_type = ResourceType.where(
        id: @resources.resource_types_id).first

      detailed_info = {
        professional_name: professional_name,
        service_place: service_place,
        resource_type: resource_type,
        resource: @resources
      }

      render json: detailed_info
    end

    # GET /resources
    def index
      citizen = current_user.first
      professional = citizen.professional
      service_place = professional.professionals_service_places.find(
        params[:permission]).service_place

      city_hall_id = service_place.city_hall_id

      @resources = policy_scope(Resource.filter(params[:q], params[:page],
        Professional.get_permission(current_user[1])))

      authorize @resources, :index?

      render json: @resources
    end

    # GET /resources/1
    def show
      begin
        authorize @resources, :show?
      rescue
        render json: {
          # errors: ["You're not allowed to view this resource."]
          errors: ["Você não tem permissão para visualizar este recurso!"]
        }, status: 403
        return
      end

      if @resources.nil?
        render json: {
          # errors: ["Resource #{params[:id]} does not exist."]
          errors: ["Recurso #{params[:id]} não existe!"]
        }, status: 404
      else
        render json: @resources
      end
    end

    # POST /resources
    def create
      # Current citizen
      citizen = current_user.first

      # Current professional
      professional = citizen.professional

      # Service place for current professional
      service_place_id =  professional.professionals_service_places.find(
        params[:permission]).service_place

      @resources = Resource.new(resource_params)
      @resources.active = true

      if @resources.service_place_id.nil?
        @resources.service_place_id = service_place_id
      end

      begin
        authorize @resources, :create?
      rescue
        render json: {
          # errors: ["You're not allowed to create a resource in this service place."]
          errors: ["Você não tem permissão para criar um recurso neste local de atendimento!"]
        }, status: 403
        return
      end

      if @resources.save
        render json: @resources, status: :created
      else
        render json: @resources.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /resources/1
    def update
      begin
        authorize @resources, :update?
      rescue
        render json: {
          # errors: ["You're not allowed to update a resource in this service place."]
          errors: ["Você não tem permissão para atualizar um recurso neste local de atendimento!"]
        }, status: 403
        return
      end

      if @resources.update(resource_params)
        render json: @resources
      else
        render json: @resources.errors, status: :unprocessable_entity
      end
    end

    # DELETE /resources/1
    def destroy
      if @resources.nil?
        render json: {
          # errors: ["Resource #{params[:id]} does not exist."]
          errors: ["Recurso #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @resources, :destroy?
        rescue
          render json: {
            # errors: ["You're not allowed to deactivate a resource in this service place."]
            errors: ["Você não tem permissão para desativar um recurso neste local de atendimento!"]
          }, status: 403
          return
        end

        @resources.active = false

        if @resources.save!
          render json: @resources
        else
          render json: @resources.errors, status: :unprocessable_entity
        end
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      begin
        @resources = Resource.find(params[:id])
      rescue
        @resources = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def resource_params
      params.require(:resource).permit(
        :resource_types_id,
        :service_place_id,
        :professional_responsible_id,
        :minimum_schedule_time,
        :maximum_schedule_time,
        :active,
        :brand,
        :model,
        :label,
        :note
      )
    end
  end
end
