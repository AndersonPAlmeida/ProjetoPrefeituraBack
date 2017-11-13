module Api::V1
  class ResourceBookingsController < ApplicationController
    include Authenticable
    # include HasPolicies - Should I define policies? If yes, how? Who can do what?     
    
    before_action :set_resource_booking, only: [:show, :update, :destroy]

    # GET /resource_bookings
    def index
      @resource_booking = Resource_booking.all_active

      render json: @resource_booking
    end

    # GET /resource_bookings/1
    def show
      if @resource_booking.nil?
        render json: {
          errors: ["Resource booking #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @resource_booking
      end
    end

    # POST /resource_bookings
    def create
      @resource_booking = Resource_booking.new(resource_booking_params)
      @resource_booking.active = true

      if @resource_booking.save and Resource_shift.where(id: @resource_booking.resource_shift_id)
        render json: @resource_booking, status: :created
      else
        render json: @resource_booking.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /resource_bookings/1
    def update
      if @resource_booking.nil? 
        render json: {
          errors: ["Resource booking #{params[:id]} does not exist."]
        }, status: 404
      else
        if @resource_booking.update(resource_booking_params) and Resource_shift.where(id: @resource_booking.resource_shift_id)
          render json: @resource_booking
        else
          render json: @resource_booking.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /resource_bookings/1
    def destroy
      if @resource_booking.nil?
        render json: {
          errors: ["Resource booking #{params[:id]} does not exist."]
        }, status: 404
      else
        @resource_booking.active = false
        @resource_booking.save!
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_booking
      begin
        @resource_booking = Resource_booking.find(params[:id])
      rescue
        @resource_booking = nil
      end
    end

    # Only allow a trusted parameter "white list" through.

    def resource_booking_params.permit(
        :address_id,
        :resource_shift_id,
        :situation_id,
        :citizen_id,
        :booking_reason,
        :booking_start_time,
        :booking_end_time
      )
    end
  end
end