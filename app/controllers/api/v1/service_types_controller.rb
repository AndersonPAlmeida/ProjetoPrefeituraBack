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
            if @service_type.nil?
              render json: {
                errors: ["Service type #{params[:id]} does not exist."]
              }, status: 400
            else
              render json: @service_type
            end
	  end

	  # POST /service_types
	  def create
	    @service_type = ServiceType.new(service_type_params)

	    if @service_type.save
	      render json: @service_type, status: :created
	    else
	      render json: @service_type.errors, status: :unprocessable_entity
	    end
	  end

	  # PATCH/PUT /service_types/1
	  def update
            if @service_type.nil?
              render json: {
                errors: ["Service type #{params[:id]} does not exist."]
              }, status: 400
            else
              if @service_type.update(service_type_params)
                render json: @service_type
              else
                render json: {
                  errors: [@service_type.errors, status: :unprocessable_entity]
                }, status: 422
              end
            end

	  end

	  # DELETE /service_types/1
	  def destroy
            if @service_type.nil?
              render json: {
                errors: ["Service type #{params[:id]} does not exist."]
              }, status: 400
            else
              @service_type.active = false
              @service_type.save!
            end
	  end

	  private
	    # Use callbacks to share common setup or constraints between actions.
	    def set_service_type
	      begin
	        @service_type = ServiceType.find(params[:id])
	      rescue
		@service_type = nil
	      end
	    end

	    # Only allow a trusted parameter "white list" through.
	    def service_type_params
	      params.require(:service_type).permit(:active, :sector_id, :description)
	    end
	  end
end
