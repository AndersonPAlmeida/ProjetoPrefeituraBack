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
  class SectorsController < ApplicationController
    include Authenticable

    before_action :set_sector, only: [:show, :update, :destroy]

    # GET /sectors
    def index
      if (not params[:schedule].nil?) and (params[:schedule] == 'true')
        if params[:citizen_id].nil?
          @citizen = current_user[0]
        else
          begin
            @citizen = Citizen.find(params[:citizen_id])
          rescue
            render json: {
              # errors: ["Citizen #{params[:citizen_id]} does not exist."]
              errors: ["Cidadão #{params[:citizen_id]} não existe!"]
            }, status: 404
            return
          end
        end

        # Allow request only if the citizen is reachable from current user
        begin
          authorize @citizen, :schedule?
        rescue
          render json: {
            # errors: ["You're not allowed to schedule for this citizen."]
            errors: ["Você não tem permissão para agendar para este cidadão!"]
          }, status: 403
          return
        end

        @sectors = Sector.schedule_response(@citizen).to_json
        render json: @sectors
        return
      else
        @sectors = policy_scope(Sector.filter(params[:q], params[:page],
          Professional.get_permission(current_user[1])))
      end


      if @sectors.nil?
        render json: {
          # errors: ["You're not allowed to view sectors"]
          errors: ["Você não tem permissão para listar setores!"]
        }, status: 403
      else
        response = Hash.new
        response[:num_entries] = @sectors.total_count
        response[:entries] = @sectors.index_response

        render json: response.to_json
      end
    end

    # GET /sectors/1
    def show
      if @sector.nil?
        render json: {
          # errors: ["Sector #{params[:id]} does not exist."]
          errors: ["Setor #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @sector, :show?
        rescue
          render json: {
            # errors: ["You're not allowed to view this sector."]
            errors: ["Você não tem permissão para visualizar este setor!"]
          }, status: 403
          return
        end

        render json: @sector.complete_info_response
      end
    end

    # POST /sectors
    def create
      @sector = Sector.new(sector_params)
      @sector.active = true

      begin
        authorize @sector, :create?
      rescue
        render json: {
          # errors: ["You're not allowed to create this sector."]
          errors: ["Você não tem permissão para criar este setor!"]
        }, status: 403
        return
      end

      if @sector.save
        render json: @sector, status: :created
      else
        render json: @sector.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /sectors/1
    def update
      if @sector.nil?
        render json: {
          # errors: ["Sector #{params[:id]} does not exist."]
          errors: ["Setor #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @sector, :update?
        rescue
          render json: {
            # errors: ["You're not allowed update this sector."]
            errors: ["Você não tem permissão para atualizar este setor!"]
          }, status: 403
          return
        end

        if @sector.update(sector_params)
          render json: @sector
        else
          render json: @sector.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /sectors/1
    def destroy
      if @sector.nil?
        render json: {
          # errors: ["Sector #{params[:id]} does not exist."]
          errors: ["Setor #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @sector, :destroy?
        rescue
          render json: {
            # errors: ["You're not allowed deactivate this sector."]
            errors: ["Você não tem permissão para desativar este setor!"]
          }, status: 403
          return
        end

        @sector.active = false
        if @sector.save
          render json: @sector, status: :ok
        else
          render json: @sector.errors, status: :unprocessable_entity
        end
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_sector
      begin
        @sector = Sector.find(params[:id])
      rescue
        @sector = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def sector_params
      params.require(:sector).permit(
        :active,
        :absence_max,
        :blocking_days,
        :cancel_limit,
        :city_hall_id,
        :description,
        :previous_notice,
        :name,
        :schedules_by_sector
      );
    end
  end
end
