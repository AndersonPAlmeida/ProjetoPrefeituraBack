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
  class CityHallsController < ApplicationController
    include Authenticable
    require "#{Rails.root}/lib/image_parser.rb"

    before_action :set_city_hall, only: [ :show, :update, :destroy, :picture,
                                          :upload_picture ]

    # GET /city_halls
    def index
      @city_halls = policy_scope(CityHall.filter(params[:q], params[:page],
        Professional.get_permission(current_user[1])))


      if @city_halls.nil?
        render json: {
          # errors: ["You don't have the permission to view city halls."]
          errors: ["Você não tem permissão para listar prefeituras!"]
        }, status: 403
        return
      else
        response = Hash.new
        response[:num_entries] = @city_halls.total_count
        response[:entries] = @city_halls.index_response

        render json: response.to_json
        return
      end
    end


    # GET /city_halls/1
    def show
      if @city_hall.nil?
        render json: {
          # errors: ["City hall #{params[:id]} does not exist."]
          errors: ["Prefeitura #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @city_hall, :show?
        rescue
          render json: {
            # errors: ["You don't have the permission to view this city hall."]
            errors: ["Você não tem permissão para visualizar esta prefeitura!"]
          }, status: 403
          return
        end

        render json: @city_hall.complete_info_response
      end
    end


    # POST /city_halls
    def create
      @city_hall = CityHall.new(city_hall_params)

      begin
        authorize @city_hall, :create?
      rescue
        render json: {
          # errors: ["You don't have the permission to create city halls."]
          errors: ["Você não tem permissão para criar prefeituras!"]
        }, status: 403
        return
      end

      if @city_hall.save
        render json: @city_hall.complete_info_response, status: :created
      else
        render json: @city_hall.errors, status: :unprocessable_entity
      end
    end


    # PATCH/PUT /city_halls/1
    def update
      if @city_hall.nil?
        render json: {
          # errors: ["City hall #{params[:id]} does not exist."]
          errors: ["Prefeitura #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @city_hall, :update?
        rescue
          render json: {
            # errors: ["You don't have the permission to update city halls."]
            errors: ["Você não tem permissão para atualizar prefeituras!"]
          }, status: 403
          return
        end

        if @city_hall.update(city_hall_params)
          render json: @city_hall.complete_info_response
        else
          render json: @city_hall.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /city_halls/1
    def destroy
      if @city_hall.nil?
        render json: {
          # errors: ["City hall #{params[:id]} does not exist."]
          errors: ["Prefeitura #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @city_hall, :destroy?
        rescue
          render json: {
            # errors: ["You're not allowed to destroy this city hall."]
            errors: ["Você não tem permissão para remover esta prefeitura!"]
          }, status: 403
          return
        end

        @city_hall.active = false

        if @city_hall.save!
          render json: @city_hall, status: :ok
        else
          render json: @city_hall.errors, status: :unprocessable_entity
        end
      end
    end

    # GET /city_hall/1/picture
    def picture
      if @city_hall.nil?
        render json: {
          # errors: ["City hall #{params[:id]} does not exist."]
          errors: ["Prefeitura #{params[:id]} não existe!"]
        }, status: 404
      else
        # Allow request only if the citizen is reachable from current user
        begin
          authorize @city_hall, :picture?
        rescue
          render json: {
            # errors: ["You're not allowed to view this city hall."]
            errors: ["Você não tem permissão para visualizar esta prefeitura!"]
          }, status: 403
          return
        end

        path = @city_hall.avatar.path

        if path.nil?
          render json: {
            # errors: ["City hall #{params[:id]} does not have a picture."]
            errors: ["Prefeitura #{params[:id]} não possui uma foto!"]
          }, status: 404
        else
          if not params[:size].nil?
            path.sub!('original', params[:size])
          end

          begin
            send_file path,
              type: @city_hall.avatar_content_type,
              disposition: 'inline'
          rescue
            send_file "public/missing.png",
              type: "image/png",
              disposition: 'inline'
          end
        end
      end
    end

    # POST /city_hall/1/upload_picture
    def upload_picture
      if @city_hall.nil?
        render json: {
          # errors: ["City hall #{params[:id]} does not exist."]
          errors: ["Prefeitura #{params[:id]} não existe!"]
        }, status: 404
      else
        # Allow request only if the citizen is reachable from current user
        begin
          authorize @city_hall, :update?
        rescue
          render json: {
            # errors: ["You're not allowed to update this city hall."]
            errors: ["Você não tem permissão para atualizar esta prefeitura!"]
          }, status: 403
          return
        end

        if params[:avatar]
          begin
            @city_hall.avatar = Agendador::Image::Parser.parse(params[:avatar])
          ensure
            Agendador::Image::Parser.clean_tempfile
          end

          @city_hall.save

          render json: {
            # errors: ["City hall avatar uploaded!"]
            errors: ["Avatar da prefeitura atualizado!"]
          }, status: 201
        else
          render json: {
            # errors: ["Avatar parameter undefined."]
            errors: ["Avatar indefinido!"]
          }, status: 400
        end
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_city_hall
      begin
        @city_hall = CityHall.find(params[:id])
      rescue
        @city_hall = nil
      end
    end


    # Only allow a trusted parameter "white list" through.
    def city_hall_params
      params.require(:city_hall).permit(
        :active,
        :address_number,
        :address_complement,
        :block_text,
        :citizen_access,
        :citizen_register,
        :cep,
        :description,
        :email,
        :name,
        :neighborhood,
        :phone1,
        :phone2,
        :schedule_period,
        :show_professional,
        :support_email,
        :url
      )
    end
  end
end
