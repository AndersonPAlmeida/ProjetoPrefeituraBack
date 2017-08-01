module Api::V1
  class SchedulesController < ApplicationController
    include Authenticable

    before_action :set_schedule, only: [:show, :update, :destroy, :confirm, :confirmation]

    rescue_from Pundit::NotAuthorizedError, with: :schedule_error_description

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

    # GET /schedules/1/confirmation
    def confirmation
      if @schedule.nil?
        render json: {
          errors: [" Schedule #{params[:id]} does not exist."]
        }, status: 404
      else
        # Workaround for Pundit's lack of parameter passing
        # May be nil, that case is handled in SchedulePolicy
        @schedule.target_citizen_id = params[:citizen_id]

        # Check if the current citizen can schedule for the given citizen
        authorize @schedule, :permitted?

        # Check if there's no conflict concerning the given citizen's schedules
        authorize @schedule, :no_conflict?

        # Return Json containing the necessary information for displaying the
        # schedule confirmation to the user
        render json: @schedule.confirmation_data
      end
    end

    # PUT /schedules/1/confirm
    def confirm
      if @schedule.nil?
        render json: {
          errors: [" Schedule #{params[:id]} does not exist."]
        }, status: 404
      else
        # Update the schedule's situation
        @schedule.situation_id = Situation.agendado.id

        # Update the schedule's account_id
        if params[:citizen_id].nil?
          binding.pry
          @schedule.citizen_id = current_user[0].id
        else
          @schedule.citizen_id = params[:citizen_id]
        end

        if @schedule.save
          render json: @schedule
        else
          render json: {
            errors: ["The schedule could not be confirmed."]
          }, status: 400
        end
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
        @schedule.situation_id = Situation.where(description: "Cancelado").first.id
        @schedule.save!
      end
    end

    private

    # Rescue Pundit exception for providing more details in reponse
    def schedule_error_description(exception)

      # Get SchedulePolicy method's name responsible for raising exception 
      policy_name = exception.message.split(' ')[3]

      case policy_name
      when "permitted?"
        render json: {
          errors: ["You're not allowed to schedule for this citizen."]
        }, status: 422
      when "no_conflict?"
        render json: {
          errors: ["This citizen is already scheduled in the given time."]
        }, status: 409
      end
    end

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
        :citizen_id,
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
