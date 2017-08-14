class ScheduleSerializer < ActiveModel::Serializer
  attributes :id, 
    :citizen_id,
    :citizen_ajax_read, 
    :note, 
    :professional_ajax_read, 
    :reminder_email_sent,
    :reminder_read, 
    :remainder_time, 
    :service_start_time, 
    :service_end_time 

  belongs_to :service_place
  belongs_to :shift
  belongs_to :situation
end
