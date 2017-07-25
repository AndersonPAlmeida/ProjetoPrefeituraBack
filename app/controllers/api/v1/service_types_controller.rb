module Api::V1
  class ServiceTypesController < ApplicationController
    include Authenticable

    before_action :set_service_type, only: [:show, :update, :destroy]

    # GET /service_types
    def index
      if params[:sector_id].nil?
        @service_types = ServiceType.all
      else
        @service_types = ServiceType.schedule_response(params[:sector_id]).to_json
      end

      render json: @service_types
    end

    # GET /service_types/1
    def show
      if @service_type.nil?
        render json: {
          errors: ["Service type #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @service_type
      end
    end

    # POST /service_types
    def create
      @service_type = ServiceType.new(service_type_params)

      if @service_type.save
        render json: @service_type, status: :created
      else
        render json: @service_type.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /service_types/1
    def update
      if @service_type.nil?
        render json: {
          errors: ["Service type #{params[:id]} does not exist."]
        }, status: 404
      else
        if @service_type.update(service_type_params)
          render json: @service_type
        else
          render json: {
            errors: [@service_type.errors, status: :unprocessable_entity]
          }, status: 422
        end
      end
    end

    # DELETE /service_types/1
    def destroy
      if @service_type.nil?
        render json: {
          errors: ["Service type #{params[:id]} does not exist."]
        }, status: 404
      else
        @service_type.active = false
        @service_type.save!
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_service_type
      begin
        @service_type = ServiceType.find(params[:id])
      rescue
        @service_type = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def service_type_params
      params.require(:service_type).permit(
        :id,
        :active,
        :description,
        :sector_id
      )
    end
  end
end
