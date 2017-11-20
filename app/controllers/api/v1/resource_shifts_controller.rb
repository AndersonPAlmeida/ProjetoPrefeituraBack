module Api::V1
  class ResourceShiftsController < ApplicationController
    include Authenticable
    # include HasPolicies - Should I define policies? If yes, how? Who can do what?     
    
    before_action :set_resource_shift, only: [:show, :update, :destroy]

    # GET /resource_shifts
    def index
      @resource_shift = Resource_shift.all_active

      render json: @resource_shift
    end

    # GET /resource_shifts/1
    def show
      if @resource_shift.nil?
        render json: {
          errors: ["Resource shift #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @resource_shift
      end
    end

    # POST /resource_shifts
    def create
      @resource_shift = Resource_shift.new(resource_shift_params)
      @resource_shift.active = true
      @resource_shift.borrowed = false

      if @resource_shift.save and Resource.where(id: @resource_shift.resource_id)
        render json: @resource_shift, status: :created
      else
        render json: @resource_shift.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /resource_shifts/1
    def update
      if @resource_shift.nil?
        render json: {
          errors: ["Resource shift #{params[:id]} does not exist."]
        }, status: 404
      else
        if @resource_shift.update(resource_shift_params) and Resource.where(id: @resource_shift.resource_id)
          render json: @resource_shift
        else
          render json: @resource_shift.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /resource_shifts/1
    def destroy
      if @resource_shift.nil?
        render json: {
          errors: ["Resource shift #{params[:id]} does not exist."]
        }, status: 404
      else
        @resource_shift.active = false
        @resource_shift.save!
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_shift
      begin
        @resource_shift = Resource_shift.find(params[:id])
      rescue
        @resource_shift = nil
      end
    end

    # Only allow a trusted parameter "white list" through.

    def resource_shift_params
      params.require(:resource_shift).permit(
        :resource_id,
        :professional_responsible_id,
        :next_shift_id,
        :execution_start_time,
        :execution_end_time,
        :notes
      )
    end
  end
end
