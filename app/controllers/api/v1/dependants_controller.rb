module Api::V1
  class DependantsController < ApplicationController 
    include Authenticable

    before_action :set_dependant, only: [:show, :update, :destroy]

    # GET /dependants
    def index
      @dependants = Dependant.all

      render json: @dependants
    end

    # GET /dependants/1
    def show
      if @dependant.nil?
        render json: {
          errors: ["Dependant #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @dependant
      end
    end

    # POST /dependants
    def create
      @dependant = Dependant.new(dependant_params)

      if @dependant.save
        render json: @dependant, status: :created
      else
        render json: @dependant.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /dependants/1
    def update
      if @dependant.nil?
        render json: {
          errors: ["Dependant #{params[:id]} does not exist."]
        }, status: 404
      else
        if @dependant.update(dependant_params)
          render json: @dependant
        else
          render json: @dependant.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /dependants/1
    def destroy
      if @dependant.nil?
        render json: {
          errors: ["Dependant #{params[:id]} does not exist."]
        }, status: 404
      else
        @dependant.active = false
        @dependant.deactivated = DateTime.now
        @dependant.save
      end
    end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_dependant
      @dependant = Dependant.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def dependant_params
      params.require(:dependant).permit(
        :id,
        :active,
        :citizen_id,
        :deactivation
      )
    end
  end
end
