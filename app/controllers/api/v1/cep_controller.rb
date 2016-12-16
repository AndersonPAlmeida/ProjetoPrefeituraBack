module Api::V1
  class CepController < ApplicationController

    # POST /validate_cep
    def validate
      if not CepValidator.valid_format?(cep_params[:number])
        render json: {
          errors: ["Invalid CEP."]
        }, status: 422
        return
      end

      address = Address.get_address(cep_params[:number])

      # Verify if cep is valid
      if address.nil?
        render json: {
          errors: ["Invalid CEP."]
        }, status: 422
      else
        # City may not exists due to tests without setting up cities
        if address[:city_id].nil?
          render json: {
            errors: ["City not registered."]
          }, status: 404
          return
        end

        city = City.find(address[:city_id])

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
