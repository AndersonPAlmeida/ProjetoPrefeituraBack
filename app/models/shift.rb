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

  around_create :create_schedules

  private

    def create_schedules
      yield

      schedules = Array.new
      start_t = self.execution_start_time
      end_t = self.execution_end_time 

      # Split shift execution time to fit service_amounts schedules
      # each with (schedule_t * 60) minutes
      range_t = (end_t.hour * 60 + end_t.min) - (start_t.hour * 60 + start_t.min)
      schedule_t = range_t / self.service_amount 

      # Creates service_amount schedules
      self.service_amount.times do |i|
        end_t = start_t + (schedule_t * 60)

        schedule = Schedule.new(
          shift_id: self.id,
          situation_id: Situation.disponivel.id,
          service_place_id: self.service_place_id,
          citizen_ajax_read: 1,
          professional_ajax_read: 1,
          reminder_read: 1,
          service_start_time: start_t,
          service_end_time: end_t
        )

        schedules.append(schedule)
        start_t = end_t  
        schedule.save!
      end
    end
end
