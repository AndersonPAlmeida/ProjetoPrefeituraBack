module Api::V1
  class CitizensController < ApiController
    before_action :set_citizen, only: [:show, :update, :destroy]

    # GET /citizens
    def index
      @citizens = Citizen.all_active

      render json: @citizens
    end

    # GET /citizens/1
    def show
      if @citizen.nil?
        render json: {
          errors: ["User #{params[:id]} does not exist."]
        }, status: 404
      else
        render json: @citizen
      end
    end

    # POST /citizens
    def create
      @citizen = Citizen.new(citizen_params)
      @citizen.active = true

      city = CepController.get_city(citizen_params[:cep])
      if city.nil?
        @citizen.city_id = nil
      else
        @citizen.city_id = CepController.get_city(citizen_params[:cep]).id
      end

      if @citizen.save
        render json: @citizen, status: :created
      else
        render json: @citizen.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /citizens/1
    def update
      if @citizen.nil?
        render json: {
          errors: ["User #{params[:id]} does not exist."]
        }, status: 404
      else
        if @citizen.update(citizen_params)
          render json: @citizen
        else
          render json: @citizen.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /citizens/1
    def destroy
      if @citizen.nil?
        render json: {
          errors: ["User #{params[:id]} does not exist."]
        }, status: 404
      else
        @citizen.active = false
        @citizen.save!
      end
    end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_citizen
      begin
        @citizen = Citizen.find(params[:id])
      rescue
        @citizen = nil
      end
    end

    # Only allow a trusted parameter "white list" through.
    def citizen_params
      params.require(:citizen).permit(
        :id,
        :account_id,
        :active,
        :address_complement,
        :address_number,
        :address_street,
        :birth_date,
        :cep,
        :city_id,
        :cpf,
        :email,
        :name,
        :neighborhood,
        :note,
        :pcd,
        :phone1,
        :phone2,
        :photo_content_type,
        :photo_file_name,
        :photo_file_size,
        :photo_update_at,
        :rg
      )
    end
  end
end
