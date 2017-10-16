module Api::V1
  class ServiceTypesController < ApplicationController
    include Authenticable
    include HasPolicies

    before_action :set_service_type, only: [:show, :update]

    # GET /service_types
    def index
      if params[:sector_id].nil? or params[:schedule].nil? or params[:schedule] != 'true'
        # TODO: The returned columns are different when request by a adm_c3sl
        @service_types = policy_scope(ServiceType.filter(params[:q], params[:page]))
      else
        @service_types = ServiceType.schedule_response(params[:sector_id]).to_json

        render json: @service_types
        return
      end

      render json: @service_types.index_response
    end

    # GET /service_types/1
    def show
      if @service_type.nil?
        render json: {
          errors: ["Service type #{params[:id]} does not exist."]
        }, status: 404
      else
        authorize @service_type, :show?

        render json: @service_type.complete_info_response
      end
    end

    # POST /service_types
    def create
      @service_type = ServiceType.new(service_type_params)

      authorize @service_type, :create?

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

        authorize @service_type, :update?

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

    # Rescue Pundit exception for providing more details in reponse
    def policy_error_description(exception)
      # Set @policy_name as the policy method that raised the error
      super

      case @policy_name
      when "show?"
        render json: {
          errors: ["You're not allowed to view this service type."]
        }, status: 403
      when "create?"
        render json: {
          errors: ["You're not allowed to create this service type."]
        }, status: 403
      when "update?"
        render json: {
          errors: ["You're not allowed to update this service type."]
        }, status: 403
      end
    end

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
