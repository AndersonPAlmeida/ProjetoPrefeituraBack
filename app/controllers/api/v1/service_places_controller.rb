module Api::V1
	class ServicePlacesController < ApiController
	  before_action :set_service_place, only: [:show, :update, :destroy]

	  # GET /service_places
	  def index
	    @service_places = ServicePlace.all

	    render json: @service_places
	  end

	  # GET /service_places/1
	  def show
      if @service_place.nil?
        render json: {
          errors: ["Service place #{params[:id]} does not exist."]
        }, status: 404
      else
	      render json: @service_place
      end
	  end

	  # POST /service_places
	  def create
	    @service_place = ServicePlace.new(service_place_params)

	    if @service_place.save
	      render json: @service_place, status: :created, location: @service_place
	    else
	      render json: @service_place.errors, status: :unprocessable_entity
	    end
	  end

	  # PATCH/PUT /service_places/1
	  def update
      if @service_place.nil?
        render json: {
          errors: ["Service place #{params[:id]} does not exist."]
        }, status: 404
      else
        if @service_place.update(service_place_params)
          render json: @service_place
        else
          render json: @service_place.errors, status: :unprocessable_entity
        end
      end
	  end

	  # DELETE /service_places/1
	  def destroy
      if @service_place.nil?
        render json: {
          errors: ["Service place #{params[:id]} does not exist."]
        }, status: 404
      else
  	    @service_place.active = false
        @service_place.save
      end
	  end

	private

	  # Use callbacks to share common setup or constraints between actions.
	  def set_service_place
      begin
	      @service_place = ServicePlace.find(params[:id])
      rescue
        @service_place = nil
      end
	  end

	  # Only allow a trusted parameter "white list" through.
	  def service_place_params
	    params.require(:service_place).permit(
        :active,
        :address_number,
        :address_street,
        :name,
        :neighborhood,
        :address_complement,
        :cep,
        :email,
        :phone1,
        :phone2,
        :url
      )
	  end
	end
end
