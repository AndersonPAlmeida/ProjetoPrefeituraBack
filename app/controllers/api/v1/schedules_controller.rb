module Api::V1
  class SchedulesController < ApiController
    before_action :set_schedule, only: [:show, :update, :destroy]

    # GET /schedules
    def index
      @schedules = Schedule.all

      render json: @schedules
    end

    # GET /schedules/1
    def show
      if @schedule.nil?
        render json: {
          errors: [" Schedule #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @schedule
      end
    end

    # POST /schedules
    def create
      @schedule = Schedule.new(schedule_params)

      if @schedule.save
        render json: @schedule, status: :created
      else
        render json: @schedule.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /schedules/1
    def update
      if @schedule.nil?
        render json: {
          errors: ["Schedule #{params[:id]} does not exist."]
        }, status: 404
      else
        if @schedule.update(schedule_params)
          render json: @schedule
        else
          render json: @schedule.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /schedules/1
    def destroy
      if @schedule.nil?
        render json: {
          errors: ["Schedule #{params[:id]} does not exist."]
        }, status: 404
      else
        @schedule.destroy
      end
    end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_schedule
      begin
        @schedule = Schedule.find(params[:id])
      rescue
        @schedule = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def schedule_params
      params.require(:schedule).permit(
        :id,
        :account_id,
        :citizen_ajax_read,
        :note,
        :professional_ajax_read,
        :reminder_read,
        :reminder_email_sent,
        :reminder_time,
        :service_start_time,
        :service_end_time,
        :service_place_id,
        :shift_id,
        :situation_id
      )
    end
  end
end
