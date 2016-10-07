class Block < ActiveRecord::Base
  
  # Associations #
  belongs_to :account
  belongs_to :sector
  belongs_to :dependant, optional: true
end
