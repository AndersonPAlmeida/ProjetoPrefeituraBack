class Shift < ApplicationRecord

  # Associations #
  belongs_to :service_place
  belongs_to :service_type
  belongs_to :shift, optional: true
  has_one    :shift,
              foreign_key: :next_shift_id,
              class_name: "Shift"
  belongs_to :professional,
              optional: true,
              foreign_key: :professional_responsible_id,
              class_name: "Professional"
  belongs_to :professional_2,
              optional: true,
              foreign_key: :professional_performer_id,
              class_name: "Professional"
  has_many    :schedules

  # Validations #
  validates_presence_of :execution_start_time
                        :execution_end_time
                        :service_amount
end
