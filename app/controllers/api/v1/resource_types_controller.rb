module Api::V1
  class Api::V1::ResourceTypesController < ApplicationController
    include Authenticable
    # include HasPolicies - Should I define policies? If yes, how? Who can do what?     
    
    before_action :set_resource_type, only: [:show, :update, :destroy]

    # GET /resource_types
    def index
      @resource_type = Resource_type.all_active

      render json: @resource_type
    end

    # GET /resource_types/1
    def show
      if @resource_type.nil?
        render json: {
          errors: ["Resource type #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @resource_type
      end
    end

    # POST /resource_types
    def create
      @resource_type = Resource_type.new(resource_type_params)
      @resource_type.active = true

      if @resource_type.save
        render json: @resource_type, status: :created
      else
        render json: @resource_type.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /resource_types/1
    def update
      if @resource_type.nil?
        render json: {
          errors: ["Resource type #{params[:id]} does not exist."]
        }, status: 404
      else
        if @resource_type.update(resource_type_params)
          render json: @resource_type
        else
          render json: @resource_type.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /resource_types/1
    def destroy
      if @resource_type.nil?
        render json: {
          errors: ["Resource type #{params[:id]} does not exist."]
        }, status: 404
      else
        @resource_type.active = false
        @resource_type.save!
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_type
      begin
        @resource_type = Resource_type.find(params[:id])
      rescue
        @resource_type = nil
      end
    end

    # Only allow a trusted parameter "white list" through.

    def resource_type_params
      params.require(:resource_type).permit(
        :city_hall_id,
        :name,
        :active,
        :mobile,
        :description
      )
    end
  end    
end
