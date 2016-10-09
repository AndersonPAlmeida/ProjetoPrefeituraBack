class ShiftSerializer < ActiveModel::Serializer
  attributes :id, 
             :execution_start_time, 
             :execution_end_time,
             :notes,
             :service_amount

  belongs_to :service_place
  belongs_to :service_type
  has_one :shift, :foreign_key => :next_shift_id, :class_name => "Shift"
  belongs_to :professional, :foreign_key => :professional_responsible_id,
                            :class_name => "Professional"
  belongs_to :professional_2, :foreign_key => :professional_performer_id,
                              :class_name => "Professional"
end
