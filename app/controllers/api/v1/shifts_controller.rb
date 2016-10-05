module Api::V1
	class ShiftsController < ApiController 
	  before_action :set_shift, only: [:show, :update, :destroy]

	  # GET /shifts
	  def index
	    @shifts = Shift.all

	    render json: @shifts
	  end

	  # GET /shifts/1
	  def show
	    if @shift.nil?
	      render json: {
	        errors: ["Shift #{params[:id]} does not exist."]
	      }, status: 400
	    else
	      render json: @shift
	    end
	  end

	  # POST /shifts
	  def create
	    @shift = Shift.new(shift_params)

	    if @shift.save
	      render json: @shift, status: :created
	    else
	      render json: @shift.errors, status: :unprocessable_entity
	    end
	  end

	  # PATCH/PUT /shifts/1
	  def update
	    if @shift.update(shift_params)
	      render json: @shift
	    else
	      render json: @shift.errors, status: :unprocessable_entity
	    end
	  end

	  # DELETE /shifts/1
	  def destroy
	    if @shift.nil?
	      render json: {
	        errors: ["Shift #{params[:id]} does not exist."]
	      }, status: 400
	    else
	      @shift.active = false
	      @shift.save!
	    end
	  end

	  private
	    # Use callbacks to share common setup or constraints between actions.
	    def set_shift
	      begin
	        @shift = Shift.find(params[:id])
	      rescue
	        @shift = nil
	      end
	    end

	    # Only allow a trusted parameter "white list" through.
	    def shift_params
	      params.require(:shift).permit(:service_place_id, :service_type_id, 
	                                    :next_shift_id, :professional_performer_id, 
	                                    :professional_responsible_id, 
	                                    :execution_start_time, :execution_end_time, 
	                                    :service_amount, :notes)
	    end
	end
end
