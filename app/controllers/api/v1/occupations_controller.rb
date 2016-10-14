module Api::V1
  class OccupationsController < ApiController
    before_action :set_occupation, only: [:show, :update, :destroy]

    # GET /occupations
    def index
      @occupations = Occupation.all_active

      render json: @occupations
    end

    # GET /occupations/1
    def show
      if @occupation.nil?
        render json: {
          errors: ["Occupation #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @occupation
      end
    end

    # POST /occupations
    def create
      @occupation = Occupation.new(occupation_params)
      @occupation.active = true

      if @occupation.save
        render json: @occupation, status: :created
      else
        render json: @occupation.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /occupations/1
    def update
      if @occupation.nil?
        render json: {
          errors: ["Occupation #{params[:id]} does not exist."]
        }, status: 404
      else
        if @occupation.update(occupation_params)
          render json: @occupation
        else
          render json: @occupation.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /occupations/1
    def destroy
      if @occupation.nil?
        render json: {
          errors: ["Occupation #{params[:id]} does not exist."]
        }, status: 404
      else
        @occupation.active = false
        @occupation.save!
      end
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_occupation
      begin
        @occupation = Occupation.find(params[:id])
      rescue
        @occupation = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def occupation_params
      params.require(:occupation).permit(
        :active,
        :city_hall_id,
        :description,
        :name
      )
    end
  end
end
