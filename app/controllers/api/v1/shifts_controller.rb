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
  class ShiftsController < ApplicationController
    include Authenticable

    before_action :set_shift, only: [:show, :update, :destroy]

    # GET /shifts
    def index
      @shifts = policy_scope(Shift.filter(params[:q], params[:page],
                             Professional.get_permission(current_user[1])))

      if @shifts.nil?
        render json: {
          # errors: ["You don't have the permission to view shifts."]
          errors: ["Você não tem permissão para listar escalas!"]
        }, status: 403
      else
        response = Hash.new
        response[:num_entries] = @shifts.total_count
        response[:entries] = @shifts.index_response

        render json: response
      end
    end

    # GET /shifts/1
    def show
      if @shift.nil?
        render json: {
          # errors: ["Shift #{params[:id]} does not exist."]
          errors: ["Escala #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @shift, :show?
        rescue
          render json: {
            # errors: ["You're not allowed to view this shift."]
            errors: ["Você não tem permissão para visualizar esta escala!"]
          }, status: 403
          return
        end

        render json: @shift.complete_info_response
      end
    end

    # POST /shifts
    def create
      success = false
      error_message = nil

      raise_rollback = -> (error) {
        error_message = error
        raise ActiveRecord::Rollback
      }

      ActiveRecord::Base.transaction do
        shift_params[:shifts].each do |s|
          shift = Shift.new(s)

          begin
            authorize shift, :create?
          rescue
            # raise_rollback.call(["You're not allowed to create this shift."])
            raise_rollback.call(["Você não tem permissão para criar esta escala!"])
          end

          raise_rollback.call(shift.errors.to_hash) unless shift.save
        end

        success = true
      end

      if success
        render json: shift_params.as_json
      else
        render json: {
          errors: error_message
        }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /shifts/1
    def update
      if @shift.nil?
        render json: {
          # errors: ["Shift #{params[:id]} does not exist."]
          errors: ["Escala #{params[:id]} não existe!"]
        }, status: 404
      else
        success = false
        error_message = nil

        raise_rollback = -> (error) {
          error_message = error
          raise ActiveRecord::Rollback
        }

        ActiveRecord::Base.transaction do
          @shift.assign_attributes(shift_update_params)

          begin
            authorize @shift, :update?
          rescue
            # raise_rollback.call(["You're not allowed to update this shift."])
            raise_rollback.call(["Você não tem permissão para atualizar esta escala!"])
          end

          raise_rollback.call(@shift.errors.to_hash) unless @shift.save
          @shift.update_schedules()
          success = true
        end

        if success
          render json: @shift.complete_info_response
        else
          render json: error_message, status: :unprocessable_entity
        end
      end
    end

    # DELETE /shifts/1
    def destroy
      if @shift.nil?
        render json: {
          # errors: ["Shift #{params[:id]} does not exist."]
          errors: ["Escala #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @shift, :destroy?
        rescue
          render json: {
            # errors: ["You're not allowed to view this shift."]
            errors: ["Você não tem permissão para visualizar esta escala!"]
          }, status: 403
          return
        end

        @shift.service_amount = 0
        @shift.save!
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_shift
      begin
        @shift = Shift.find(params[:id])
      rescue
        @shift = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def shift_update_params
      params.require(:shift).permit(
        :execution_start_time,
        :execution_end_time,
        :notes,
        :professional_performer_id,
        :professional_responsible_id,
        :service_amount,
        :service_place_id,
        :service_type_id
      )
    end

    # Only allow a trusted parameter "white list" through.
    def shift_params
      params.permit(shifts: [
        :execution_start_time,
        :execution_end_time,
        :notes,
        :professional_performer_id,
        :professional_responsible_id,
        :service_amount,
        :service_place_id,
        :service_type_id
      ])
    end
  end
end
