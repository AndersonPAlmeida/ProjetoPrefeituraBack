class Schedule < ApplicationRecord
  include Searchable

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

  # @params id [Integer] Citizen the schedules are being returned for 
  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @return [Json] every schedule for each dependant from a citizen and the 
  #   citizen himself for showing in the schedule history screen
  def self.citizen_history(id, params, npage)

    # Citizen's dependants
    citizens = Citizen.where(responsible_id: id).pluck(:id, :name)

    response = Hash.new.as_json
    
    # Citizen's info along with the schedules associated with him
    response["id"] = id
    response["name"] = Citizen.find(id).name
    response["schedules"] = Schedule.where(citizen_id: id)
      .filter(params, npage)
      .map { |i| i.show_data }.as_json
      

    response["dependants"] = [].as_json

    # Schedules assigned to each citizen's dependant
    citizens.each do |i,name|
      entry = Hash.new.as_json

      entry["id"] = i
      entry["name"] = name
      entry["schedules"] = Schedule.where(citizen_id: i)
        .filter(params, npage)
        .map { |i| i.show_data }.as_json

      response["dependants"].append(entry)
    end

    return response
  end

  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @return [ActiveRecords] filtered schedules
  def self.filter(params, npage)
    return search(search_params(params), npage)
  end

  private

  # Translates incoming search parameters to ransack patterns
  # @params params [ActionController::Parameters] Parameters for searching
  # @return [Hash] filtered and translated parameters
  def self.search_params(params)
    filter = {"service_type_id" => "shift_service_type_id_eq", 
              "service_place_id" => "service_place_id_eq", 
              "sector_id" => "shift_service_type_sector_id_eq", 
              "situation_id" => "situation_id_eq"}

    return filter_search_params(params, filter, nil) 
  end
end
