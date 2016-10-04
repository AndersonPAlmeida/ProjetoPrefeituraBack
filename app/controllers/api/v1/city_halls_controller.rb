module Api::V1
  class CityHallsController < ApiController
    before_action :set_city_hall, only: [:show, :update, :destroy]

    # GET /city_halls
    def index
      @city_halls = CityHall.all

      render json: @city_halls
    end

    # GET /city_halls/1
    def show
      if @city_hall.nil?
        render json: {
          errors: ["City hall #{params[:id]} does not exist."]
        }, status: 400
      else
        render json: @city_hall
      end
    end

    # POST /city_halls
    def create
      @city_hall = CityHall.new(city_hall_params)

      if @city_hall.save
        render json: @city_hall, status: :created
      else
        render json: @city_hall.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /city_halls/1
    def update
      if @city_hall.nil?
        render json: {
          errors: ["City hall #{params[:id]} does not exist."]
        }, status: 400
      else
        if @city_hall.update(city_hall_params)
          render json: @city_hall
        else
          render json: @city_hall.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /city_halls/1
    def destroy
      if @city_hall.nil?
        render json: {
          errors: ["City hall #{params[:id]} does not exist."]
        }, status: 400
      else
        @city_hall.active = false
        @city_hall.save!
      end
    end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_city_hall
      begin
        @city_hall = CityHall.find(params[:id])
      rescue
        @city_hall = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def city_hall_params
      params.require(:city_hall).permit(
        :city_id, 
        :active, 
        :address_number, 
        :address_street, 
        :block_text, 
        :cep, 
        :citizen_access, 
        :citizen_register, 
        :name, 
        :neighborhood, 
        :previous_notice, 
        :schedule_period, 
        :address_complement, 
        :description, 
        :email, 
        :logo_content_type, 
        :logo_file_name, 
        :logo_file_size, 
        :logo_updated_at, 
        :phone1, 
        :phone2, 
        :support_email, 
        :show_professional, 
        :url
      )
    end
  end
end
