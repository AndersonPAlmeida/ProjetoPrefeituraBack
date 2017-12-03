module Api::V1
  class ShiftsController < ApplicationController
    include Authenticable

    before_action :set_shift, only: [:show, :update, :destroy]

    # GET /shifts
    def index
      @shifts = Shift.all

      render json: @shifts
    end

    # GET /shifts/1
    def show
      if @shift.nil?
        render json: {
          errors: ["Shift #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @shift.complete_info_response
      end
    end

    # POST /shifts
    def create
      success = false
      error_message = nil

      raise_rollback = -> (error) {
        error_message = error
        raise ActiveRecord::Rollback
      }

      ActiveRecord::Base.transaction do
        shift_params[:shifts].each do |s|
          shift = Shift.new(s)
          raise_rollback.call(shift.errors.to_hash) unless shift.save
        end

        success = true
      end

      if success
        render json: shift_params.as_json
      else
        render json: error_message, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /shifts/1
    def update
      if @shift.nil?
        render json: {
          errors: ["Shift #{params[:id]} does not exist."]
        }, status: 404
      else
        if @shift.update(shift_params)
          render json: @shift
        else
          render json: @shift.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /shifts/1
    def destroy
      if @shift.nil?
        render json: {
          errors: ["Shift #{params[:id]} does not exist."]
        }, status: 404
      else
        @shift.service_amount = 0
        @shift.save!
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_shift
      begin
        @shift = Shift.find(params[:id])
      rescue
        @shift = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def shift_params
      params.permit(shifts: [
        :execution_start_time,
        :execution_end_time,
        :notes,
        :professional_performer_id,
        :professional_responsible_id,
        :service_amount,
        :service_place_id,
        :service_type_id
      ])
    end
  end
end
