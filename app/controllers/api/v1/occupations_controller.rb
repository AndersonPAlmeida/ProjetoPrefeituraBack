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
  class OccupationsController < ApplicationController
    include Authenticable

    before_action :set_occupation, only: [:show, :update, :destroy]

    # GET /occupations
    def index
      @occupations = policy_scope(Occupation.filter(params[:q], params[:page],
        Professional.get_permission(current_user[1])))

      if @occupations.nil?
        render json: {
          # errors: ["You don't have the permission to view occupations."]
          errors: ["Você não tem permissão para listar cargos!"]
        }, status: 403
      else
        response = Hash.new
        response[:num_entries] = @occupations.total_count
        response[:entries] = @occupations.index_response

        render json: response
      end
    end

    # GET /occupations/1
    def show
      if @occupation.nil?
        render json: {
          # errors: ["Occupation #{params[:id]} does not exist."]
          errors: ["Cargo #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @occupation, :show?
        rescue
          render json: {
            # errors: ["You're not allow to see this occupation."]
            errors: ["Você não tem permissão para visualizar este cargo!"]
          }, status: 403
          return
        end

        render json: @occupation.complete_info_response
      end
    end

    # POST /occupations
    def create
      @occupation = Occupation.new(occupation_params)

      begin
        authorize @occupation, :create?
      rescue
        render json: {
          # errors: ["You're not allow to create this occupation."]
          errors: ["Você não tem permissão para criar este cargo!"]
        }, status: 403
        return
      end

      if @occupation.save
        render json: @occupation.complete_info_response, status: :created
      else
        render json: @occupation.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /occupations/1
    def update
      if @occupation.nil?
        render json: {
          # errors: ["Occupation #{params[:id]} does not exist."]
          errors: ["Cargo #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @occupation, :update?
        rescue
          render json: {
            # errors: ["You're not allow to update this occupation."]
            errors: ["Você não tem permissão para atualizar este cargo!"]
          }, status: 403
          return
        end

        if @occupation.update(occupation_params)
          render json: @occupation.complete_info_response
        else
          render json: @occupation.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /occupations/1
    def destroy
      if @occupation.nil?
        render json: {
          # errors: ["Occupation #{params[:id]} does not exist."]
          errors: ["Cargo #{params[:id]} não existe!"]
        }, status: 404
      else
        @occupation.active = false
        @occupation.save!
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_occupation
      begin
        @occupation = Occupation.find(params[:id])
      rescue
        @occupation = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def occupation_params
      params.require(:occupation).permit(
        :active,
        :city_hall_id,
        :description,
        :name
      )
    end
  end
end
