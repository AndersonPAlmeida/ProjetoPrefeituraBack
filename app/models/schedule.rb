class Schedule < ApplicationRecord

  # Associations #
  belongs_to :situation
  belongs_to :shift
  belongs_to :service_place
  belongs_to :account, optional: true

  # Validations #
  validates_presence_of :citizen_ajax_read,
    :professional_ajax_read,
    :reminder_read,
    :service_start_time,
    :service_end_time

  # Workaround for Pundit's lack of parameter passing
  attr_accessor :target_citizen_id


  def confirmation_data
    self.as_json(only: [
      :id, :service_start_time, :service_end_time, :note
    ]).merge({
      sector_name: self.shift.service_type.sector.name,
      service_type_name: self.shift.service_type.description,
      service_place_name: self.service_place.name,
      service_place_address_street: self.service_place.address_street,
      service_place_address_number: self.service_place.address_number
    })
  end
end
