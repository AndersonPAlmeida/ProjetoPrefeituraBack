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
  class ResourceBookingsController < ApplicationController
    include Authenticable

    before_action :set_resource_booking, only: [:show, :update, :destroy]

    def get_extra_info
      resource_booking = []

      @resource_booking = policy_scope(ResourceBooking.filter(
        params[:q], params[:page], params[:permission]))

      if @resource_booking.nil?
        render json: {
          # errors: ["You don't have the permission to view resource bookings."]
          errors: ["Você não tem permissão para listar agendamentos de recursos!"]
        }, status: 403
      else
        @resource_booking.each do |rb|
          resource = Resource.where(id: ResourceShift.where(
            id: rb.resource_shift_id).first.resource_id).first

          resource_type = ResourceType.where(
            id: resource.resource_types_id).first

          resource_booking << {
            'citizen_name': Citizen.where(id: rb.citizen_id).first.name,
            'resource': resource,
            'resource_type_name': resource_type.name,
            'resource_type_description': resource_type.description,
            'resource_booking_id': rb.id
          }
        end

        render json: resource_booking
      end
    end

    # GET /resource_bookings
    # You should pass the parameter view togheter with permission:
    # localhost:3000/resource_bookings&permission=2&view=professional
    def index
      @resource_booking = policy_scope(ResourceBooking.filter(
        params[:q], params[:page], params[:permission]))

      if @resource_booking.nil?
        render json: {
          # errors: ["You don't have the permission to view resource bookings."]
          errors: ["Você não tem permissão para visualizar agendamentos de recursos!"]
        }, status: 403
      else
        render json: @resource_booking
      end
    end

    # GET /resource_bookings/1
    def show
      if @resource_booking.nil?
        render json: {
          # errors: ["Resource booking #{params[:id]} does not exist."]
          errors: ["Agendamento de recurso #{params[:id]} não existe!"]
        }, status: 404
        return
      end

      begin
        authorize @resource_booking, :show?
      rescue
        render json: {
          # errors: ["You do not have permission to see this booking"]
          errors: ["Você não tem permissão para visualizar este agendamento!"]
        }, status: :unprocessable_entity
        return
      end

      render json: @resource_booking
    end

    # POST /resource_bookings
    def create
      @resource_booking = ResourceBooking.new(resource_booking_params)
      @resource_booking.active = true
      @resource_booking.status = "Requisitado"

      begin
        authorize @resource_booking, :create?
      rescue
        render json: {
          # errors: ["You do not have permission to create this booking"]
          errors: ["Você não tem permissão para criar este agendamento!"]
        }, status: :unprocessable_entity
        return
      end

      if @resource_booking.save
        render json: @resource_booking, status: :created
      else
        render json: @resource_booking.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /resource_bookings/1
    def update
      if @resource_booking.nil?
        render json: {
          # errors: ["Resource booking #{params[:id]} does not exist."]
          errors: ["Agendamento de recurso #{params[:id]} não existe!"]
        }, status: 404
        return
      end

      begin
        authorize @resource_booking, :update?
      rescue
        render json: {
          # errors: ["You do not have permission to update this booking"]
          errors: ["Você não tem permissão para atualizar este agendamento!"]
        }, status: :unprocessable_entity
        return
      end

      if @resource_booking.update(resource_booking_params)
        render json: @resource_booking
      else
        render json: @resource_booking.errors, status: :unprocessable_entity
      end
    end

    # DELETE /resource_bookings/1
    def destroy
      if @resource_booking.nil?
        render json: {
          # errors: ["Resource booking #{params[:id]} does not exist."]
          errors: ["Agendamento de recurso #{params[:id]} não existe!"]
        }, status: 404
        return
      end

      begin
        authorize @resource_booking, :destroy?
      rescue
        render json: {
          # errors: ["You do not have permission to delete this booking"]
          errors: ["Você não tem permissão para remover este agendamento!"]
        }, status: :unprocessable_entity
        return
      end

      @resource_booking.active = false
      @resource_booking.status = "Indisponível"
      @resource_booking.save!
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_booking
      begin
        @resource_booking = ResourceBooking.find(params[:id])
      rescue
        @resource_booking = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def resource_booking_params
      params.require(:resource_booking).permit(
        :service_place_id,
        :resource_shift_id,
        :situation_id,
        :citizen_id,
        :booking_reason,
        :booking_start_time,
        :booking_end_time,
        :status
      )
    end

  end
end
