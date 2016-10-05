class ShiftSerializer < ActiveModel::Serializer
  belongs_to :service_place
  belongs_to :service_type
  has_one :shift, :foreign_key => :next_shift_id, :class_name => "Shift"
  belongs_to :professional, :foreign_key => :professional_responsible_id,
                            :class_name => "Professional"
  belongs_to :professional_2, :foreign_key => :professional_performer_id,
                              :class_name => "Professional"
  attributes :id, :execution_start_time, :execution_end_time,
             :service_amount, :notes
end
