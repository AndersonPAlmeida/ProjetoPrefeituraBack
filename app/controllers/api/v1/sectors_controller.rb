module Api::V1
  class SectorsController < ApplicationController
    include Authenticable

    before_action :set_sector, only: [:show, :update, :destroy]

    # GET /sectors
    def index
      if (not params[:schedule].nil?) and (params[:schedule] == 'true') and
        (not params[:citizen_id].nil?)

        citizen = Citizen.find(params[:citizen_id])
        @sectors = Sector.schedule_response(citizen)
      else
        @sectors = policy_scope(Sector)
      end

      render json: @sectors
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
