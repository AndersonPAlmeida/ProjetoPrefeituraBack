class Schedule < ApplicationRecord

  # Associations #
  belongs_to :situation
  belongs_to :shift
  belongs_to :service_place
  belongs_to :account, optional: true

  # Validations #
  validates_presence_of :citizen_ajax_read
                        :professional_ajax_read
                        :reminder_read
                        :service_start_time
                        :service_end_time
end
