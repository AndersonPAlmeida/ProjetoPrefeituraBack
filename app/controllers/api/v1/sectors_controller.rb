module Api::V1
  class SectorsController < ApplicationController
    include Authenticable
    include HasPolicies

    before_action :set_sector, only: [:show, :update, :destroy]

    # GET /sectors
    def index
      if (not params[:schedule].nil?) and (params[:schedule] == 'true')
        if params[:citizen_id].nil?
          @citizen = current_user[0]
        else
          begin
            @citizen = Citizen.find(params[:citizen_id])
          rescue
            render json: {
              errors: ["Citizen #{params[:citizen_id]} does not exist."]
            }, status: 404
            return
          end
        end

        # Allow request only if the citizen is reachable from current user
        authorize @citizen, :schedule?

        @sectors = Sector.schedule_response(@citizen).to_json
      else
        @sectors = policy_scope(Sector)
      end

      if @sectors.nil?
        render json: {
          errors: ["You're not allowed to view sectors"]
        }, status: 403
      else
        render json: @sectors
      end
    end

    # GET /sectors/1
    def show
      if @sector.nil?
        render json: {
          errors: ["Sector #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @sector
      end
    end

    # POST /sectors
    def create
      @sector = Sector.new(sector_params)

      if @sector.save
        render json: @sector, status: :created
      else
        render json: @sector.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /sectors/1
    def update
      if @sector.nil?
        render json: {
          errors: ["Sector #{params[:id]} does not exist."]
        }, status: 404
      else
        if @sector.update(sector_params)
          render json: @sector
        else
          render json: @sector.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /sectors/1
    def destroy
      if @sector.nil?
        render json: {
          errors: ["Sector #{params[:id]} does not exist."]
        }, status: 404
      else
        @sector.active = false
        @sector.save!
      end
    end

    private

    # Rescue Pundit exception for providing more details in reponse
    def policy_error_description(exception)
      # Set @policy_name as the policy method that raised the error
      super

      case @policy_name
      when "schedule?"
        render json: {
          errors: ["You're not allowed to schedule for this citizen."]
        }, status: 403
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_sector
      begin
        @sector = Sector.find(params[:id])
      rescue
        @sector = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def sector_params
      params.require(:sector).permit(
        :id,
        :absence_max,
        :active,
        :blocking_days,
        :cancel_limit,
        :city_hall_id,
        :description,
        :name,
        :schedules_by_sector
      );
    end
  end
end
