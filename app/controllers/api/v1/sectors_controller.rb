module Api::V1
  class SectorsController < ApiController
    before_action :set_sector, only: [:show, :update, :destroy]

    # GET /sectors
    def index
      @sectors = Sector.all

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
          render json: {
            errors: [@sector.errors, status: :unprocessable_entity]
          }, status: 422
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
