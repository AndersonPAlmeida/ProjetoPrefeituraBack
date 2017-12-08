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

  delegate :name, to: :service_place, prefix: true
  delegate :name, to: :citizen, prefix: true, allow_nil: true

  delegate :description, to: :situation, prefix: true


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
      service_place_address_street: self.service_place.address_street,
      service_place_address_number: self.service_place.address_number,
      situation: self.situation.description
    })
  end

  # @params id [Integer] Citizen the schedules are being returned for 
  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @return [Json] every schedule for each dependant from a citizen and the 
  # citizen himself for showing in the schedule history screen
  def self.citizen_history(id, params, npage)
    # Citizen's dependants
    citizens = Citizen.where(responsible_id: id).pluck(:id, :name)

    response = Hash.new.as_json
    
    schedules = Schedule.where(citizen_id: id)
    sectors = get_sectors_response(schedules.where(situation_id: 2))
    
    schedules = schedules.filter(params, npage)
      .map { |i| i.show_data }

    # Citizen's info along with the schedules associated with him
    response["id"] = id
    response["name"] = Citizen.find(id).name
    response["schedules"] = Hash.new.as_json
    response["schedules"]["entries"] = schedules.as_json
    response["schedules"]["sectors"] = sectors
    response["dependants"] = [].as_json


    # Schedules assigned to each citizen's dependant
    citizens.each do |i,name|
      schedules = Schedule.where(citizen_id: i)
      sectors = get_sectors_response(schedules.where(situation_id: 2))
      schedules = schedules.filter(params, npage)
        .map { |j| j.show_data }


      entry = Hash.new.as_json

      entry["id"] = i
      entry["name"] = name
      entry["schedules"] = Hash.new.as_json
      entry["schedules"]["entries"] = schedules.as_json
      entry["schedules"]["sectors"] = sectors

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

  def self.get_sectors_response(schedules)
    # Get every sector_id present in schedules
    sector_ids = schedules.joins({shift: :service_type})
      .pluck(:"service_types.sector_id")

    # Count frequency of each sector
    freq = sector_ids.each_with_object(Hash.new(0)) { |key,hash| 
      hash[key] += 1
    }

    # Build array of sectors containing the amount of schedules
    # of the given citizen in each present sector
    sectors = Sector.where(id: sector_ids)
      .as_json(only: [:id, :name, :schedules_by_sector])
      .each_with_object([]) { |key, hash| 
        key["schedules"] = freq[key["id"]]; 
        hash.append(key)
      }
  end

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
