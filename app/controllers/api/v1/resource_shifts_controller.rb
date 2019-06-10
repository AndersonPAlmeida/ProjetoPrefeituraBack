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
  class ResourceShiftsController < ApplicationController
    include Authenticable

    before_action :set_resource_shift, only: [:show, :update, :destroy]

    # GET /resource_shifts
    def get_professional_resource_shift
      authorize ResourceShift

      professional_name = Citizen.where(
                          account_id:Account.where(
                                id:Professional.where(
                                    id: params[:id]
                                ).first.id
                          ).first.id
                        ).first.name

      render json: {
        professional_name: professional_name
      }
    end

    # GET /resource_shifts
    def index
      @resource_shift = policy_scope(ResourceShift.filter(
        params[:q], params[:page], params[:permission]))

      if @resource_shift.nil?
        render json: {
          # errors: ["You don't have the permission to view resource shifts."]
          errors: ["Você não tem permissão para listar escalas de recursos!"]
        }, status: 403
      else
        render json: @resource_shift
      end
    end

    # GET /resource_shifts/1
    def show
      begin
        authorize @resource_shift, :show?
      rescue
        render json: {
          # errors: ["This resource does not belong to your city"]
          errors: ["Este recurso não pertence à sua cidade!"]
        }, status: :unprocessable_entity
        return
      end

      if @resource_shift.nil?
        render json: {
          # errors: ["Resource shift #{params[:id]} does not exist."]
          errors: ["Escala de recurso #{params[:id]} não existe!"]
        }, status: 404
      else
        render json: @resource_shift
      end
    end

    # POST /resource_shifts
    def create
      @resource_shift = ResourceShift.new(resource_shift_params)
      @resource_shift.active = true
      @resource_shift.borrowed = false

      resource = Resource.where(id: @resource_shift.resource_id)

      if !resource.first.nil?
        if resource.first.active == 1
          authorize @resource_shift, :create?

          if @resource_shift.save
            render json: @resource_shift, status: :created
          else
            render json: @resource_shift.errors, status: :unprocessable_entity
          end
        else
          render json: {
            # errors: ["The system could not create shift: Resource id #{@resource_shift.resource_id} is deactivated."]
            errors: ["Impossível criar escala: Recurso com id #{@resource_shift.resource_id} está desativado!"]
          }, status: :unprocessable_entity
        end
      else
        render json: {
          # errors: ["The system could not create shift: Resource id #{@resource_shift.resource_id} does not exist."]
          errors: ["Impossível criar escala: Recurso com id #{@resource_shift.resource_id} não existe!"]
        }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /resource_shifts/1
    def update
      if @resource_shift.nil?
        render json: {
          # errors: ["Resource shift #{params[:id]} does not exist."]
          errors: ["Escala de recurso #{params[:id]} não existe!"]
        }, status: 404

      else
        authorize @resource_shift, :update?

        if @resource_shift.update(resource_shift_params)
          render json: @resource_shift
        else
          render json: @resource_shift.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /resource_shifts/1
    def destroy
      if @resource_shift.nil?
        render json: {
          # errors: ["Resource shift #{params[:id]} does not exist."]
          errors: ["Escala de recurso #{params[:id]} não existe!"]
        }, status: 404
      else
        authorize @resource_shift, :destroy?

        @resource_shift.active = false
        @resource_shift.save!
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_shift
      begin
        @resource_shift = ResourceShift.find(params[:id])
      rescue
        @resource_shift = nil
      end
    end

    # Only allow a trusted parameter "white list" through.

    def resource_shift_params
      params.require(:resource_shift).permit(
        :resource_id,
        :professional_responsible_id,
        :next_shift_id,
        :execution_start_time,
        :execution_end_time,
        :notes,
        :active,
        :borrowed
      )
    end

  end
end
