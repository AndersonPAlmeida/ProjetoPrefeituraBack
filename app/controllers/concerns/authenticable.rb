module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_v1_account! 
  end
end
