class Block < ActiveRecord::Base
  # Associations #
  belongs_to :professional
  belongs_to :account
end
