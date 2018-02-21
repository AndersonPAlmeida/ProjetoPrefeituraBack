module Api::V1
  class ServiceTypesController < ApplicationController
    include Authenticable
    include HasPolicies

    before_action :set_service_type, only: [:show, :update]

    # GET /service_types
    def index
      if params[:sector_id].nil? or params[:schedule].nil? or params[:schedule] != 'true'
        @service_types = policy_scope(ServiceType.filter(params[:q], params[:page],
          Professional.get_permission(current_user[1])))

      else
        @service_types = ServiceType.schedule_response(params[:sector_id]).to_json

        render json: @service_types
        return
      end

      if @service_types.nil?
        render json: {
          errors: ["You don't have the permission to view service types."]
        }, status: 403
      else
        response = Hash.new
        response[:num_entries] = @service_types.total_count
        response[:entries] = @service_types.index_response

        render json: response
      end
    end


    # GET /service_types/1
    def show
      if @service_type.nil?
        render json: {
          errors: ["Service type #{params[:id]} does not exist."]
        }, status: 404
      else
        begin
          authorize @service_type, :show?
        rescue
          render json: {
            errors: ["You're not allowed to view this service type."]
          }, status: 403
          return
        end

        render json: @service_type.complete_info_response
      end
    end


    # POST /service_types
    def create
      @service_type = ServiceType.new(service_type_params)

      begin
        authorize @service_type, :create?
      rescue
        render json: {
          errors: ["You're not allowed to create this service type."]
        }, status: 403
        return
      end

      if @service_type.save
        render json: @service_type.complete_info_response, status: :created
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
        @service_type.assign_attributes(service_type_params)

        begin
          authorize @service_type, :update?
        rescue
          render json: {
            errors: ["You're not allowed to update this service type."]
          }, status: 403
          return
        end

        if @service_type.save 
          render json: @service_type
        else
          render json: {
            errors: [@service_type.errors, status: :unprocessable_entity]
          }, status: 422
        end
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
