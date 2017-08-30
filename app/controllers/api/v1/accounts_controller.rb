module Api::V1
  class AccountsController < ApplicationController 
    include Authenticable

    # GET /accounts/self
    def index  
      render json: {
        data:  current_account.token_validation_response
      }
    end
  end
end
