module Api::V1
  class ResourcesController < ApplicationController
    include Authenticable
    # include HasPolicies - Should I define policies? If yes, how? Who can do what?     
    
    before_action :set_resource, only: [:show, :update, :destroy]

    # GET /resources
    def index
      @resource = Resource.all_active

      render json: @resource
    end

    # GET /resources/1
    def show
      if @resource.nil?
        render json: {
          errors: ["Resource #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @resource
      end
    end

    # POST /resources
    def create
      @resource = Resource.new(resource_params)
      @resource.active = true

      if @resource.save
        render json: @resource, status: :created
      else
        render json: @resource.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /resources/1
    def update
      if @resource.nil?
        render json: {
          errors: ["Resource #{params[:id]} does not exist."]
        }, status: 404
      else
        if @resource.update(resource_params)
          render json: @resource
        else
          render json: @resource.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /resources/1
    def destroy
      if @resource.nil?
        render json: {
          errors: ["Resource #{params[:id]} does not exist."]
        }, status: 404
      else
        @resource.active = false
        @resource.save!
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      begin
        @resource = Resource.find(params[:id])
      rescue
        @resource = nil
      end
    end

    # Only allow a trusted parameter "white list" through.

    def resource_params
      params.require(:resource).permit(
        :resource_types_id,
        :serivce_place_id,
        :minimum_schedule_time,
        :maximum_schedule_time
        :active,
        :brand,
        :model,
        :label,
        :note
      )
    end
  end
end
