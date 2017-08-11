module Api::V1
  class DependantsController < ApplicationController 
    include Authenticable

    before_action :set_dependant, only: [:show, :update, :destroy]
    before_action :set_citizen, only: [:index]

    # GET citizens/1/dependants
    def index
      if @citizen.nil?
        render json: {
          errors: ["Citizen #{params[:id]} does not exist."]
        }, status: 404
      else
        @dependants = Dependant.where(citizens: {
          responsible_id: @citizen.id
        }).includes(:citizen)

        dependants_response = []
        @dependants.each do |item|
          dependants_response.append(item.citizen.as_json(only: [
            :id, :name, :rg, :cpf, :birth_date
          ]))
          dependants_response[-1]["id"] = item.id
        end

        render json: dependants_response.to_json
      end
    end

    # GET citizens/1/dependants/2
    def show
      if @dependant.nil?
        render json: {
          errors: ["Dependant #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @dependant
      end
    end

    # POST citizens/1/dependants
    def create
      @dependant = Dependant.new(dependant_params)

      if @dependant.save
        render json: @dependant, status: :created
      else
        render json: @dependant.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT citizens/1/dependants/2
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

    # DELETE citizens/1/dependants/2
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

    # Use callbacks to share common setup or constraints between actions.
    def set_citizen
      begin
        @citizen = Citizen.find(params[:citizen_id])
      rescue
        @citizen = nil
      end
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
