class Schedule < ApplicationRecord

  # Associations #
  belongs_to :situation
  belongs_to :shift
  belongs_to :service_place
  belongs_to :citizen, optional: true

  # Validations #
  validates_presence_of :citizen_ajax_read,
    :professional_ajax_read,
    :reminder_read,
    :service_start_time,
    :service_end_time

  # Workaround for Pundit's lack of parameter passing
  attr_accessor :target_citizen_id

  # @return [Json] schedule information for showing in confirmation screen
  # (final step of scheduling process)
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

  # @return [Json] information for showing an individual schedule 
  # in the schedule history screen
  def show_data
    self.as_json(only: [
      :id, :service_start_time 
    ]).merge({
      sector_name: self.shift.service_type.sector.name,
      service_type_name: self.shift.service_type.description,
      service_place_name: self.service_place.name,
      situation: self.situation.description
    })
  end

  # @return [Json] every schedule for each dependant from a citizen and the 
  # citizen himself for showing in the schedule history screen
  def self.citizen_history(id)
    # Citizen's dependants
    citizens = Citizen.where(responsible_id: id).pluck(:id, :name)

    # Schedules assigned to citizen
    response = Hash.new.as_json
    response["schedules"] = Schedule.where(citizen_id: id)
      .map { |i| i.show_data }.as_json

    response["dependants"] = Hash.new.as_json

    # Schedules assigned to each citizen's dependant
    citizens.each do |i,name|
      response["dependants"][name] = Schedule.where(citizen_id: i)
        .map { |i| i.show_data }.as_json
    end

    return response
  end
end
