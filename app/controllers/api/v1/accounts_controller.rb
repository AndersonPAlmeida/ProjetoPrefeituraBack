module Api::V1
  class AccountsController < ApplicationController 
    include Authenticable

    def index  
      render json: {
        data:  current_account.token_validation_response
      }
    end

  end
end
