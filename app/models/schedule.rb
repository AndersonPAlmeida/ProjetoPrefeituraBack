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

  def self.ransackable_attributes(auth_object = nil)
    super & %w(shift_service_type_id service_place_id
               situation_id shift_service_type_sector_id)
  end

  #private_class_method :ransackable_attributes

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
  # @params search_f [Lambda] Function that takes the parameters and searches 
  #   using ransack
  # @params params [Hash] Parameters for searching
  # @return [Json] every schedule for each dependant from a citizen and the 
  #   citizen himself for showing in the schedule history screen
  def self.citizen_history(id, search_f, params)

    # Citizen's dependants
    citizens = Citizen.where(responsible_id: id).pluck(:id, :name)

    response = Hash.new.as_json
    
    # Citizen's info along with the schedules associated with him
    response["id"] = id
    response["name"] = Citizen.find(id).name
    response["schedules"] = search_f.call(Schedule.where(citizen_id: id),
      search_params(params)).map { |i| i.show_data }.as_json

    response["dependants"] = [].as_json

    # Schedules assigned to each citizen's dependant
    citizens.each do |i,name|
      entry = Hash.new.as_json

      entry["id"] = i
      entry["name"] = name
      entry["schedules"] = search_f.call(Schedule.where(citizen_id: i),
        search_params(params)).map { |i| i.show_data }.as_json

      response["dependants"].append(entry)
    end

    return response
  end

  private

  # Translates incoming search parameters to ransack patterns
  # @params params [Hash] Parameters for searching
  def self.search_params(params)
    custom = Hash.new

    if params.nil?
      return nil
    end

    params.each do |k, v|
      case k
      when "service_type_id"
        custom["shift_service_type_id_eq"] = v
      when "service_place_id"
        custom["service_place_id_eq"] = v
      when "sector_id"
        custom["shift_service_type_sector_id_eq"] = v
      when "situation_id"
        custom["situation_id_eq"] = v
      end
    end

    if custom.empty?
      return nil
    end

    return custom
  end
end
