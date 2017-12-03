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
  validates_presence_of :execution_start_time,
    :execution_end_time,
    :service_amount


  #around_save :create_schedules
  after_save :create_schedules

  before_validation :check_conflict

  private

  # Check for time conflict with existing shifts for the same professional_performer
  def check_conflict
    if Shift.where.not("execution_end_time <= ? OR execution_start_time >= ?", 
                       self.execution_start_time, self.execution_end_time)
            .where(professional_performer_id: self.professional_performer_id).count > 0

      self.errors["execution_start_time"] << "Time conflict"
      raise ActiveRecord::Rollback
    end
  end

  # Creates schedules when a shift is created, the amount of schedules is 
  # specified by self.service_amount and are defined between 
  # self.execution_start_time and self.execution_end_time
  def create_schedules
    schedules = Array.new
    start_t = self.execution_start_time.utc
    end_t = self.execution_end_time.utc

    # Split shift execution time to fit service_amounts schedules
    # each with (schedule_t * 60) minutes
    range_t = (end_t.hour * 60 + end_t.min) - (start_t.hour * 60 + start_t.min)
    schedule_t = range_t / self.service_amount 

    # Creates service_amount schedules
    self.service_amount.times do |i|
      end_t = start_t + (schedule_t * 60)

      schedule_row = ["#{self.id}", "#{Situation.disponivel.id}", 
                      "#{self.service_place_id}", "1", "1", "1", 
                      "#{start_t}", "#{end_t}"]

      schedules.append(schedule_row)
      start_t = end_t  
    end

    #return false

    # Bulk insert for schedules
    Schedule.transaction do
      columns = [:shift_id, :situation_id, :service_place_id, 
                 :citizen_ajax_read, :professional_ajax_read,
                 :reminder_read, :service_start_time,
                 :service_end_time]

      Schedule.import columns, schedules, validate: true
    end
  end
end
