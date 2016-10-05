class ScheduleSerializer < ActiveModel::Serializer
  belongs_to :situation
  belongs_to :shift
  belongs_to :service_place
  attributes :id, :citizen_ajax_read, :professional_ajax_read, :reminder_read, 
             :service_start_time, :service_end_time, :note, :reminder_email_sent,
             :remainder_time, :account_id
end
