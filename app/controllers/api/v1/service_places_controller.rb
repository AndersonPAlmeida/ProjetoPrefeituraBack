module Api::V1
	class ServicePlacesController < ApplicationController
	  before_action :set_service_place, only: [:show, :update, :destroy]

	  # GET /service_places
	  def index
	    @service_places = ServicePlace.all

	    render json: @service_places
	  end

	  # GET /service_places/1
	  def show
	    render json: @service_place
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
	    if @service_place.update(service_place_params)
	      render json: @service_place
	    else
	      render json: @service_place.errors, status: :unprocessable_entity
	    end
	  end

	  # DELETE /service_places/1
	  def destroy
	    @service_place.destroy
	  end

	  private
	    # Use callbacks to share common setup or constraints between actions.
	    def set_service_place
	      @service_place = ServicePlace.find(params[:id])
	    end

	    # Only allow a trusted parameter "white list" through.
	    def service_place_params 
	      params.require(:service_place).permit(:active, :address_number, :address_street, :name, :neighborhood, :address_complement, :cep, :email, :phone1, :phone2, :url)
	    end

	end
end
