module Api::V1
  class CepController < ApplicationController

    # POST /validate_cep
    def validate
      address = CepValidator.get_address(cep_params[:number]) 

      if address.empty?
        render json: {
          errors: ["Invalid CEP."]
        }, status: 400
      else
        render json: address
      end
    end

  private

    # Only allow a trusted parameter "white list" through.
    def cep_params
      params.require(:cep).permit(:number)
    end
  end
end
