module Api::V1
  class SolicitationsController < ApiController
    before_action :set_solicitation, only: [:show, :update, :destroy]

    # GET /solicitations
    def index
      @solicitations = Solicitation.all

      render json: @solicitations
    end

    # GET /solicitations/1
    def show
      if @solicitation.nil?
        render json: {
          errors: ["Solicitation #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @solicitation
      end
    end

    # POST /solicitations
    def create
      @solicitation = Solicitation.new(solicitation_params)

      if @solicitation.save
        render json: @solicitation, status: :created#, location: @solicitation
      else
        render json: @solicitation.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /solicitations/1
    def update
      if @solicitation.nil?
        render json: {
          errors: ["Solicitation #{params[:id]} does not exist."]
        }, status: 404
      else
        if @solicitation.update(solicitation_params)
          render json: @solicitation
        else
          render json: @solicitation.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /solicitations/1
    def destroy
      if @solicitation.nil?
        render json: {
          errors: ["Solicitation #{params[:id]} does not exist."]
        }, status: 404
      else
        @solicitation.destroy
      end
    end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_solicitation
      begin
        @solicitation = Solicitation.find(params[:id])
      rescue
        @solicitation = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def solicitation_params
      params.require(:solicitation).permit(
        :city_id,
        :name,
        :cpf,
        :email,
        :cep,
        :phone,
        :sent
      )
    end
  end
end
