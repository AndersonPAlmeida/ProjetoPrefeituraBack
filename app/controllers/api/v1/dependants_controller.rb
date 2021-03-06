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
  class DependantsController < ApplicationController
    include Authenticable
    include HasPolicies

    require "#{Rails.root}/lib/image_parser.rb"

    before_action :set_dependant, only: [:show, :update, :destroy]
    before_action :set_citizen, only: [:index, :show, :update, :create]

    # GET citizens/1/dependants
    def index
      if @citizen.nil?
        render json: {
          # errors: ["Citizen #{params[:citizen_id]} does not exist."]
          errors: ["Cidadão #{params[:citizen_id]} não existe!"]
        }, status: :not_found
      else
        # Allow request only if the citizen is reachable from current user
        begin
          authorize @citizen, :show_dependants?
        rescue
          render json: {
            # errors: ["You're not allowed to view this dependant."]
            errors: ["Você não tem permissão para visualizar este dependente!"]
          }, status: 403
          return
        end

        @dependants = Dependant.where(citizens: {
          responsible_id: @citizen.id
        }).includes(:citizen)


        # Filter params should be applied only if the current user is a citizen
        if current_user[1] == "citizen"
          @dependants = @dependants.filter(params[:q], params[:page])

          response = Hash.new
          response[:num_entries] = @dependants.total_count
          response[:entries] = @dependants.index_response
        else
          response = @dependants.index_response
        end

        render json: response, status: :ok
      end
    end


    # GET citizens/1/dependants/2
    def show
      if @citizen.nil?
        render json: {
          # errors: ["Citizen #{params[:citizen_id]} does not exist."]
          errors: ["Cidadão #{params[:citizen_id]} não existe!"]
        }, status: :not_found
      else
        if @dependant.nil?
          render json: {
            # errors: ["Dependant #{params[:id]} does not exist."]
            errors: ["Dependente #{params[:id]} não existe!"]
          }, status: :not_found
        elsif @dependant.citizen.responsible_id != @citizen.id
          render json: {
            # errors: ["Dependant #{params[:id]} does not belong to citizen #{params[:citizen_id]}."]
            errors: ["Dependente #{params[:id]} não pertence ao cidadão #{params[:citizen_id]}."]
          }, status: :forbidden
        else
          # Allow request only if the citizen is reachable from current user
          begin
            authorize @citizen, :show_dependants?
          rescue
            render json: {
              # errors: ["You're not allowed to view this dependant."]
              errors: ["Você não tem permissão para visualizar este dependente!"]
            }, status: 403
            return
          end

          render json: @dependant.complete_info_response, status: :ok
        end
      end
    end


    # POST citizens/1/dependants
    def create
      if @citizen.nil?
        render json: {
          # errors: ["Citizen #{params[:citizen_id]} does not exist."]
          errors: ["Cidadão #{params[:citizen_id]} não existe!"]
        }, status: :not_found
      else
        # Allow request only if the citizen is reachable from current user
        begin
          authorize @citizen, :create_dependants?
        rescue
          render json: {
            # errors: ["You're not allowed to create dependants."]
            errors: ["Você não tem permissão para criar dependentes!"]
          }, status: 403
          return
        end

        new_params = dependant_params
        new_params[:responsible_id] = @citizen.id

        if new_params[:cep].blank?
          new_params[:cep] = @citizen.cep
        end

        # Create new citizen associated with new dependant
        citizen = Citizen.new(new_params)
        citizen.active = true

        # Add image to citizen if provided
        if params[:dependant][:image]
          begin
            params[:dependant][:image] = Agendador::Image::Parser.parse(params[:dependant][:image])
            citizen.update_attribute(:avatar, params[:dependant][:image])
          ensure
            Agendador::Image::Parser.clean_tempfile
          end
        end


        if not citizen.save
          render json: citizen.errors, status: :unprocessable_entity
        else
          @dependant = Dependant.new(citizen_id: citizen.id)

          if @dependant.save
            render json: @dependant.complete_info_response, status: :created
          else
            render json: @dependant.errors, status: :unprocessable_entity
          end
        end
      end
    end


    # PATCH/PUT citizens/1/dependants/2
    def update
      if @citizen.nil?
        render json: {
          # errors: ["Citizen #{params[:citizen_id]} does not exist."]
          errors: ["Cidadão #{params[:citizen_id]} não existe!"]
        }, status: :not_found
      else
        if @dependant.nil?
          render json: {
            # errors: ["Dependant #{params[:id]} does not exist."]
            errors: ["Dependente #{params[:id]} não existe!"]
          }, status: :not_found
        elsif @dependant.citizen.responsible_id != @citizen.id
          render json: {
            # errors: ["Dependant #{params[:id]} does not belong to citizen #{params[:id]}."]
            errors: ["Dependente #{params[:id]} não pertence ao cidadão #{params[:id]}."]
          }, status: :forbidden
        else
          # Allow request only if the citizen is reachable from current user
          begin
            authorize @citizen, :create_dependants?
          rescue
            render json: {
              # errors: ["You're not allowed to create dependants."]
              errors: ["Você não tem permissão para criar dependentes!"]
            }, status: 403
            return
          end

          new_params = dependant_params

          if not new_params[:cep].nil? and new_params[:cep].empty?
            new_params[:cep] = @citizen.cep
          end

          # Add image to citizen if provided
          if params[:dependant][:image]
            if params[:dependant][:image][:content_type] == "delete"
              @dependant.citizen.avatar.destroy
            else
              begin
                params[:dependant][:image] = Agendador::Image::Parser.parse(params[:dependant][:image])
                @dependant.citizen.update_attribute(:avatar, params[:dependant][:image])
              ensure
                Agendador::Image::Parser.clean_tempfile
              end
            end
          end

          if not new_params[:cep].nil?
            new_params[:city_id] = Address.get_city_id(new_params[:cep])
          end

          if @dependant.citizen.update(new_params) and
            render json: @dependant.complete_info_response
          else
            render json: @dependant.citizen.errors, status: :unprocessable_entity
          end
        end
      end
    end


    # DELETE citizens/1/dependants/2
    def destroy
      if @dependant.nil?
        render json: {
          # errors: ["Dependant #{params[:id]} does not exist."]
          errors: ["Dependente #{params[:id]} não existe!"]
        }, status: :not_found
      else
        @dependant.citizen.active = false
        @dependant.deactivated = DateTime.now

        @dependant.save
        @dependant.citizen.save
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_dependant
      begin
        @dependant = Dependant.find(params[:id])
      rescue
        @dependant = nil
      end
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_citizen
      begin
        @citizen = Citizen.find(params[:citizen_id])
      rescue
        @citizen = nil
      end
    end


    # Only allow a trusted parameter "white list" through.
    def dependant_params
      params.require(:dependant).permit(Citizen.keys)
    end
  end
end
