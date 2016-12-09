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
        render json: @shift
      end
    end

    # POST /shifts
    def create
      @shift = Shift.new(shift_params)

      schedules = Array.new
      start_t = @shift.execution_start_time
      end_t = @shift.execution_end_time 

      # Split shift execution time to fit service_amounts schedules
      # each with (schedule_t * 60) minutes
      range_t = (end_t.hour * 60 + end_t.min) - (start_t.hour * 60 + start_t.min)
      schedule_t = range_t / @shift.service_amount 

      if @shift.save
        # Creates service_amount schedules
        @shift.service_amount.times do |i|
          end_t = start_t + (schedule_t * 60)
          schedule = Schedule.new(
            shift_id: @shift.id,
            situation_id: Situation.disponivel.id,
            service_place_id: @shift.service_place_id,
            citizen_ajax_read: 1,
            professional_ajax_read: 1,
            reminder_read: 1,
            service_start_time: start_t,
            service_end_time: end_t
          )

          schedules.append(schedule)
          start_t = end_t  
          schedule.save!
        end

        render json: @shift, status: :created
      else
        render json: @shift.errors, status: :unprocessable_entity
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
      params.require(:shift).permit(
        :id,
        :execution_start_time,
        :execution_end_time,
        :next_shift_id,
        :notes,
        :professional_performer_id,
        :professional_responsible_id,
        :service_amount,
        :service_place_id,
        :service_type_id
      )
    end
  end
end
