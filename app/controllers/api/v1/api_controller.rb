module Api::V1
  class ApiController < ApplicationController

    # allow access only when an account is autheticated
    before_action :authenticate_v1_account! 
  end
end
