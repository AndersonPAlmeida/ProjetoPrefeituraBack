module Api::V1
	class ProfessionalsController < ApiController 
	  before_action :set_professional, only: [:show, :update, :destroy]

	  # GET /professionals
	  def index
	    @professionals = Professional.all

	    render json: @professionals
	  end

	  # GET /professionals/1
	  def show
      if @professional.nil?
        render json: {
          errors: ["Professional #{params[:id]} does not exist."]
        }, status: 400
      else
  	    render json: @professional
      end
	  end

	  # POST /professionals
	  def create
	    @professional = Professional.new(professional_params)

	    if @professional.save
	      render json: @professional, status: :created, location: @professional
	    else
	      render json: @professional.errors, status: :unprocessable_entity
	    end
	  end

	  # PATCH/PUT /professionals/1
	  def update
      if @professional.nil?
        render json: {
          errors: ["Professional #{params[:id]} does not exist."]
        }, status: 400
      else
        if @professional.update(professional_params)
          render json: @professional
        else
          render json: @professional.errors, status: :unprocessable_entity
        end
      end
	  end

	  # DELETE /professionals/1
	  def destroy
      if @professional.nil?
        render json: {
          errors: ["Professional #{params[:id]} does not exist."]
        }, status: 400
      else
        @professional.active = false
        @professional.save!
      end
	  end

  private

	  # Use callbacks to share common setup or constraints between actions.
	  def set_professional
	    @professional = Professional.find(params[:id])
	  end

	  # Only allow a trusted parameter "white list" through.
	  def professional_params
	    params.require(:professional).permit(
        :registration, 
        :active
      )
	  end
	end
end
