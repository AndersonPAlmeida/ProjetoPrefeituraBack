class Block < ActiveRecord::Base
  # Associations #
  belongs_to :citizen
  belongs_to :professional
  belongs_to :account
end
