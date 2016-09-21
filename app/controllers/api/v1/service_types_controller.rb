module Api::V1
	class ServiceTypesController < ApiController
	  before_action :set_service_type, only: [:show, :update, :destroy]

	  # GET /service_types
	  def index
	    @service_types = ServiceType.all

	    render json: @service_types
	  end

	  # GET /service_types/1
	  def show
	    render json: @service_type
	  end

	  # POST /service_types
	  def create
	    @service_type = ServiceType.new(service_type_params)

	    if @service_type.save
	      render json: @service_type, status: :created, location: @service_type
	    else
	      render json: @service_type.errors, status: :unprocessable_entity
	    end
	  end

	  # PATCH/PUT /service_types/1
	  def update
	    if @service_type.update(service_type_params)
	      render json: @service_type
	    else
	      render json: @service_type.errors, status: :unprocessable_entity
	    end
	  end

	  # DELETE /service_types/1
	  def destroy
	    @service_type.destroy
	  end

	  private
	    # Use callbacks to share common setup or constraints between actions.
	    def set_service_type
	      @service_type = ServiceType.find(params[:id])
	    end

	    # Only allow a trusted parameter "white list" through.
	    def service_type_params
	      params.require(:service_type).permit(:active, :sector_id, :description);
	    end
end
