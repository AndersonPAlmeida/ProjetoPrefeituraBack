module Api::V1
  class CepController < ApplicationController

    # POST /validate_cep
    def validate
      result, status = Address.get_cep_response(cep_params[:number])

      if status.nil?
        render json: result.to_json
      else
        render json: result, status: status
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
