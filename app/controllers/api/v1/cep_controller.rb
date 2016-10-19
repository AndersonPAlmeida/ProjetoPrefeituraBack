module Api::V1
  class CepController < ApplicationController

    # POST /validate_cep
    def validate
      #unless CepValidador.valid_format?(cep_params[:number])
      #  render json: {
      #    errors: ["Invalid CEP."]
      #  }, status: 422
      #end
      if not CepValidator.valid_format?(cep_params[:number])
        render json: {
          errors: ["Invalid CEP."]
        }, status: 422
        return
      end

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

    def self.get_city(cep)
      if not CepValidator.valid_format?(cep) 
        return nil
      end

      address = CepValidator.get_address(cep)
      if address.nil?
        return nil
      end

      state = State.find_by(abbreviation: address[:state])
      if state.nil?
        return nil
      end

      return City.find_by(name: address[:city], state: state.id)
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
