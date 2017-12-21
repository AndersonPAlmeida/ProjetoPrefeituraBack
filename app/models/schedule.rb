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

  # Scopes #
  scope :local_city, -> (city_id) { 
    where(service_places: {city_id: city_id}).includes(:service_places)
  }

  scope :local_city_hall, -> (city_hall_id) { 
    where(service_places: {city_hall_id: city_hall_id}).includes(:service_place)
  }

  scope :local_service_place, -> (sp_id) { 
    where(service_places: {id: sp_id}).includes(:service_place)
  }

  scope :from_professional, -> (prof_id) {
    where(shifts: {professional_performer_id: prof_id}).includes(:shift)
  }

  # Delegations #
  delegate :name, to: :service_place, prefix: true
  delegate :professional_performer_id, to: :shift

  delegate :cpf, to: :citizen, prefix: true, allow_nil: true
  delegate :name, to: :citizen, prefix: true, allow_nil: true
  delegate :description, to: :situation, prefix: true


  # Returns json response to index schedules 
  # @return [Json] response
  def self.index_response
    response = self.all.as_json(only: [
      :id, :service_start_time, 
      :service_end_time, :shift_id
    ], methods: %w(situation_description citizen_name 
      citizen_cpf professional_performer_id))

    response.map do |i| 
      i["professional_name"] = Professional.find(i["professional_performer_id"]).name
      i["service_type"] = Shift.find(i["shift_id"]).service_type.description
    end

    return response
  end

  # Used for showing receipt
  # @return [Json] detailed service_type's data
  def complete_info_response
    citizen = self.citizen
    performer = Professional.find(self.professional_performer_id)

    responsible_name = citizen.name
    if (not self.citizen.nil? and not self.citizen.responsible_id.nil?)
      responsible_name = Citizen.find(self.citizen.responsible_id).name
    end

    address = Address.get_address(self.service_place.cep)

    response = {}
    response[:citizen_data] = {
      id: citizen.id,
      name: citizen.name,
      birth_date: citizen.birth_date,
      responsible_name: responsible_name,
      cpf: citizen.cpf,
      rg: citizen.rg,
      note: self.note
    }

    response[:service_place_data] = {
      name: self.service_place.name,
      address: address.as_json(except: [
        :created_at, :updated_at, :state_id, :city_id
      ]),
      complement: self.service_place.address_complement,
      phone1: self.service_place.phone1
    }

    response[:schedule_data] = {
      id: self.id,
      service_type_name: self.shift.service_type.description,
      service_start_time: self.service_start_time,
      professional_performer: performer.name,
      situation: self.situation.description
    }
  
    return response






    #city = City.find(self.city_id)
    #state = city.state

    #return self.as_json(only: [
    #   :id, :citizen_name, :active, :cep, :address_number, :address_complement,
    #   :phone1, :phone2, :email, :url, :created_at, :updated_at
    #  ])
    #  .merge({
    #    city_hall_name: self.city_hall.name
    #  })
    #  .merge({service_types: self.service_types.as_json(only: [
    #    :id, :description
    #  ])})
    #  .merge({
    #    professionals: self.professionals.simple_index_response
    #  })
    #  .merge({city: city.as_json(except: [
    #    :ibge_code, :state_id, :created_at, :updated_at
    #  ])})
    #  .merge({state: state.as_json(except: [
    #    :ibge_code, :created_at, :updated_at
    #  ])})
    #  .merge({address: address.as_json(except: [
    #    :created_at, :updated_at, :state_id, :city_id
    #  ])})
  end


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
    schedules = schedules.filter(params, npage, "citizen")


    # Citizen's info along with the schedules associated with him
    response["id"] = id
    response["name"] = Citizen.find(id).name
    response["schedules"] = Hash.new.as_json
    response["schedules"]["num_entries"] = schedules.total_count
    response["schedules"]["entries"] = schedules.map {|i| i.show_data}.as_json
    response["schedules"]["sectors"] = sectors
    response["dependants"] = [].as_json


    # Schedules assigned to each citizen's dependant
    citizens.each do |i,name|
      schedules = Schedule.where(citizen_id: i)
      sectors = get_sectors_response(schedules.where(situation_id: 2))
      schedules = schedules.filter(params, npage, "citizen")


      entry = Hash.new.as_json

      entry["id"] = i
      entry["name"] = name
      entry["schedules"] = Hash.new.as_json
      entry["schedules"]["num_entries"] = schedules.total_count
      entry["schedules"]["entries"] = schedules.map { |j| j.show_data }.as_json
      entry["schedules"]["sectors"] = sectors

      response["dependants"].append(entry)
    end

    return response
  end


  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @params permission [String] Permission of current user
  # @return [ActiveRecords] filtered sectors
  def self.filter(params, npage, permission)
    return search(search_params(params, permission), npage)
  end


  private


  # Translates incoming search parameters to ransack patterns
  # @params params [ActionController::Parameters] Parameters for searching
  # @params permission [String] Permission of current user
  # @return [Hash] filtered and translated parameters
  def self.search_params(params, permission)

    case permission
    when "adm_c3sl"
      sortable = ["citizen_name", "citizen_cpf", "service_start_time", "service_place_name", 
                  "shift_service_type_name", "situation_description"]

      filter = {"citizen_name" => "citizen_name_cont", 
                "cpf" => "citizen_cpf_eq",
                "city_hall" => "service_place_city_hall_id_eq",
                "professional" => "shift_professional_performer_id_eq",
                "service_place" => "service_places_id_eq",
                "service_type" => "shift_service_type_id_eq",
                "situation_id" => "situation_id_eq",
                "start_time" => "service_start_time_gteq",
                "end_time" => "service_end_time_lteq",
                "s" => "s"}

    when "adm_prefeitura"
      sortable = ["citizen_name", "citizen_cpf", "service_start_time", "service_place_name", 
                  "shift_service_type_name", "situation_description"]

      filter = {"citizen_name" => "citizen_name_cont", 
                "cpf" => "citizen_cpf_eq",
                "city_hall" => "service_place_city_hall_id_eq",
                "professional" => "shift_professional_performer_id_eq",
                "service_place" => "service_places_id_eq",
                "service_type" => "shift_service_type_id_eq",
                "situation_id" => "situation_id_eq",
                "start_time" => "service_start_time_gteq",
                "end_time" => "service_end_time_lteq",
                "s" => "s"}

    when "adm_local"
      sortable = ["citizen_name", "citizen_cpf", "service_start_time", "service_place_name", 
                  "shift_service_type_name", "situation_description"]

      filter = {"citizen_name" => "citizen_name_cont", 
                "cpf" => "citizen_cpf_eq",
                "city_hall" => "service_place_city_hall_id_eq",
                "professional" => "shift_professional_performer_id_eq",
                "service_place" => "service_places_id_eq",
                "service_type" => "shift_service_type_id_eq",
                "situation_id" => "situation_id_eq",
                "start_time" => "service_start_time_gteq",
                "end_time" => "service_end_time_lteq",
                "s" => "s"}

    when "atendente_local"
      sortable = ["citizen_name", "citizen_cpf", "service_start_time", "service_place_name", 
                  "shift_service_type_name", "situation_description"]

      filter = {"citizen_name" => "citizen_name_cont", 
                "cpf" => "citizen_cpf_eq",
                "city_hall" => "service_place_city_hall_id_eq",
                "professional" => "shift_professional_performer_id_eq",
                "service_place" => "service_places_id_eq",
                "service_type" => "shift_service_type_id_eq",
                "situation_id" => "situation_id_eq",
                "start_time" => "service_start_time_gteq",
                "end_time" => "service_end_time_lteq",
                "s" => "s"}

    when "responsavel_atendimento"
      sortable = ["citizen_name", "citizen_cpf", "service_start_time", "service_place_name", 
                  "shift_service_type_name", "situation_description"]

      filter = {"citizen_name" => "citizen_name_cont", 
                "cpf" => "citizen_cpf_eq",
                "city_hall" => "service_place_city_hall_id_eq",
                "professional" => "shift_professional_performer_id_eq",
                "service_place" => "service_places_id_eq",
                "service_type" => "shift_service_type_id_eq",
                "situation_id" => "situation_id_eq",
                "start_time" => "service_start_time_gteq",
                "end_time" => "service_end_time_lteq",
                "s" => "s"}

    when "citizen"
      filter = {"service_type_id" => "shift_service_type_id_eq", 
                "service_place_id" => "service_place_id_eq", 
                "sector_id" => "shift_service_type_sector_id_eq", 
                "situation_id" => "situation_id_eq"}

    end

    return filter_search_params(params, filter, sortable) 
  end


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
end
