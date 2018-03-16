module Api::V1
  class SchedulesController < ApplicationController
    include Authenticable

    before_action :set_schedule, only: [:show, :update, :destroy, :confirm, :confirmation]

    # GET /schedules
    def index
      if not params[:history].nil?
        @schedules = Schedule.citizen_history(
          current_user[0].id, 
          params[:q], 
          params[:page],
          params[:dependant_citizen_id],
          params[:dependant_page]
        )

        render json: @schedules
        return
      elsif not params[:future].nil?
        @schedules = Schedule.citizen_future(current_user[0].id, 
                                             params[:q], params[:page])

        render json: @schedules
        return
      elsif not params[:not_available].nil?
        @schedules = policy_scope(
          Schedule.where.not(situation_id: 1)
          .filter(params[:q], params[:page], 
        Professional.get_permission(current_user[1])))


        if @schedules.empty?
          render json: {
            errors: ["No schedules found."]
          }, status: 404
        elsif @schedules.nil?
          render json: {
            errors: ["You don't have the permission to view schedules."]
          }, status: 403
        else
          response = Hash.new
          response[:num_entries] = @schedules.total_count
          response[:entries] = @schedules.index_response

          render json: response.to_json
        end

        return
      else
        if not params[:service].nil?
          @schedules = policy_scope(
            Schedule.where.not(situation_id: [1, 2, 3])
            .filter(params[:q], params[:page], 
          Professional.get_permission(current_user[1])))


          if @schedules.empty?
            render json: {
              errors: ["No schedules found."]
            }, status: 404
          elsif @schedules.nil?
            render json: {
              errors: ["You don't have the permission to view schedules."]
            }, status: 403
          else
            response = Hash.new
            response[:num_entries] = @schedules.total_count
            response[:entries] = @schedules.index_response

            render json: response.to_json
          end

          return
        else
          @schedules = policy_scope(
            Schedule.where(situation_id: [1, 2, 3])
            .filter(params[:q], params[:page], 
          Professional.get_permission(current_user[1])))


          if @schedules.empty?
            render json: {
              errors: ["No schedules found."]
            }, status: 404
          elsif @schedules.nil?
            render json: {
              errors: ["You don't have the permission to view schedules."]
            }, status: 403
          else
            response = Hash.new
            response[:num_entries] = @schedules.total_count
            response[:entries] = @schedules.index_response

            render json: response.to_json
          end

          return
        end
      end
    end


    # GET /schedules/1
    def show
      if @schedule.nil?
        render json: {
          errors: [" Schedule #{params[:id]} does not exist."]
        }, status: 404
      else
        begin
          authorize @schedule, :show?
        rescue
          render json: {
            errors: ["You're not allowed to view this schedule."]
          }, status: 422
          return
        end

        if @schedule.citizen.nil?
          render json: @schedule
        else
          render json: @schedule.complete_info_response
        end
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
        begin
          authorize @schedule, :permitted?
        rescue
          render json: {
            errors: ["You're not allowed to schedule for this citizen."]
          }, status: 422
          return
        end

        # Check if there's no conflict concerning the given citizen's schedules
        begin
          authorize @schedule, :no_conflict?
        rescue
          render json: {
            errors: ["This citizen is already scheduled in the given time."]
          }, status: 409
          return
        end

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
        # Check if schedule's situation is available
        if @schedule.situation.id != 1
          render json: {
            errors: ["This schedule is not available."]
          }, status: 409
          return
        end

        # schedule_confirm_params contains information provided in the last step
        # of scheduling process (note and remider_time)
        update_params = schedule_confirm_params

        # @schedule's situations needs to be set as "scheduled"
        update_params[:situation_id] = Situation.agendado.id

        # @schedule needs to be associated with a citizen
        if params[:citizen_id].nil?
          update_params[:citizen_id] = current_user[0].id
        else
          update_params[:citizen_id] = params[:citizen_id]
        end


        if not params[:notification].nil?

          # Get notification params
          notification = notification_params

          # Associates notification to account being schedule for
          notification["account_id"] = Citizen.find(update_params[:citizen_id]).account_id
          notification["schedule_id"] = @schedule.id
          notification["read"] = false

          # Create notification
          @notification = Notification.new(notification)

          begin
            authorize @notification, :create?
          rescue
            render json: {
              errors: ["You are not authorized to create this notification."]
            }, status: 403
            return
          end
        end


        # This request is successful if both schedule and notification 
        # operations are successful
        if @schedule.update(update_params)
          if not params[:notification].nil?
            @notification.save
          end

          render json: @schedule
        else
          render json: @schedule.errors, status: :unprocessable_entity
        end
      end
    end


    # GET /schedules/schedule_per_type
    def schedule_per_type
      permission = Professional.get_permission(current_user[1])

      if permission == 'adm_c3sl'
        city_hall_id = params[:city_hall_id]
      elsif permission == 'adm_prefeitura' or permission == 'adm_local'
        professional = current_user[0].professional
        city_hall_id = professional.professionals_service_places
          .find(current_user[1]).service_place.city_hall_id
      else
        render json: {
          errors: ["You're not allowed to view this report."]
        }, status: 422
        return
      end

      startt = params[:start_time]
      endt = params[:end_time]

      @schedules = Schedule.schedule_per_type(city_hall_id, startt, endt)

      render json: @schedules
    end


    # NEVER USED (TODO: Check if is save to remove - definitely not safe to leave it there)
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
        begin
          authorize @schedule, :update?

          # Citizen can only update scheduled schedules (situation == Agendado) 
          if ((current_user[1] == "citizen") and 
              (schedule_update_params[:situation_id].to_i != 3))
            raise "Error"
          end
        rescue
          render json: {
            errors: ["You are not allowed to modify this schedule"]
          }, status: 403
          return
        end

        if @schedule.update(schedule_update_params)
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

    # Use callbacks to share common setup or constraints between actions.
    def set_schedule
      begin
        @schedule = Schedule.find(params[:id])
      rescue
        @schedule = nil
      end
    end


    # Only allow a trusted parameter "white list" through. (Used in confirm
    # request)
    def schedule_confirm_params
      params.require(:schedule).permit(
        :note,
        :reminder_time
      )
    end


    # Only allow updates on the schedule's situation
    def schedule_update_params
      params.require(:schedule).permit(
        :situation_id
      )
    end


    # Only allow a trusted parameter "white list" through.
    def notification_params
      params.require(:notification).permit(
        :account_id,
        :schedule_id,
        :resource_schedule_id,
        :reminder_time,
        :read,
        :content,
        :reminder_email,
        :reminder_email_sent          
      )
    end


    # Only allow a trusted parameter "white list" through.
    def schedule_params
      params.require(:schedule).permit(
        :citizen_id,
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
