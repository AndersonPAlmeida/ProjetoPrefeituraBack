module Api::V1
  class CitizensController < ApplicationController
    before_action :set_citizen, only: [:show, :update, :destroy]

    # GET /citizens
    def index
      @citizens = Citizen.all

      render json: @citizens
    end

    # GET /citizens/1
    def show
      render json: @citizen
    end

    # POST /citizens
    def create
      @citizen = Citizen.new(citizen_params)

      if @citizen.save
        render json: @citizen, status: :created, location: @citizen
      else
        render json: @citizen.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /citizens/1
    def update
      if @citizen.update(citizen_params)
        render json: @citizen
      else
        render json: @citizen.errors, status: :unprocessable_entity
      end
    end

    # DELETE /citizens/1
    def destroy
      @citizen.destroy
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_citizen
        @citizen = Citizen.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def citizen_params
        params.require(:citizen).permit(:birth_date, :name, :rg, 
                                        :address_complement, :address_number, 
                                        :address_street, :cep, :cpf, :email, 
                                        :neighborhood, :note, :pcd, :phone1, 
                                        :phone2, :photo_content_type, 
                                        :photo_file_name, :photo_file_size, 
                                        :photo_update_at)
      end
  end
end
