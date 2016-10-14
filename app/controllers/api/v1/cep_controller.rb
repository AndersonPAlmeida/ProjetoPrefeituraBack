module Api::V1
  class CepController < ApplicationController

    # POST /validate_cep
    def validate
      address = CepValidator.get_address(cep_params[:number]) 

      # Verify if cep is valid
      if address.empty?
        render json: {
          errors: ["Invalid CEP."]
        }, status: 422
      else
        city = City.find_by(name: address[:city])
        if not city.nil?
          city_hall = CityHall.where(city_id: city.id)

          # Verify if the city obtained from cep is registered
          if city_hall.empty?
            render json: {
              errors: ["City not registered."]
            }, status: 404
          else
            render json: address
          end
        else
          render json: {
            errors: ["City not registered."]
          }, status: 404
        end
      end
    end

  private

    # Only allow a trusted parameter "white list" through.
    def cep_params
      params.require(:cep).permit(
        :number
      )
    end
  end
end
