module Api::V1
  class CepController < ApplicationController

    # POST /validate_cep
    def validate
      only_registered = true

      if not cep_params[:only_registered].nil?
        only_registered = cep_params[:only_registered]
      end

      result, status = Address.get_cep_response(
        cep_params[:number], only_registered)

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
        :number,
        :only_registered
      )
    end
  end
end
