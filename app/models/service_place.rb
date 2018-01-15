class ServicePlace < ApplicationRecord
  include Searchable

  # Associations #
  belongs_to :city
  belongs_to :city_hall

  has_many :professionals_service_places
  has_many :professionals, through: :professionals_service_places
  has_many :resource

  has_and_belongs_to_many :accounts
  has_and_belongs_to_many :service_types

  # Validations #
  validates_presence_of :address_number
  validates_presence_of :name
  validates_presence_of :cep

  validates_length_of :name, maximum: 255
  validates_length_of :address_number, 
    within: 0..10,
    allow_blank: true

  validates_numericality_of :address_number,
    only_integer: true,
    allow_blank: true

  around_save :create_service_place

  # Scopes #
  scope :all_active, -> {
    where(active: true)
  }

  scope :local_city_hall, -> (city_hall_id) { 
    where(city_hall_id: city_hall_id)
  }

  # Delegations #
  delegate :id, to: :city_hall, prefix: true
  delegate :name, to: :city_hall, prefix: true
  delegate :name, to: :city, prefix: true
  delegate :state_name, to: :city


  # Get every available schedule from the current service_place given a 
  # service_type
  #
  # @param service_type_id [Integer] id from specified service_type
  # @return [Json] reponse containing necessary information for scheduling
  def get_schedules(service_type_id)
    response = self.as_json(only: [:id, :name])

    # Add schedule_period from city_hall to response's json
    response["schedule_period"] = self.city_hall.schedule_period

    # Add every schedule's necessary information to reponse's json
    response["schedules"] = Schedule
      .where(shifts: { service_type_id: service_type_id })
      .includes(:shift)
      .where(service_place_id: response["id"])
      .where(situation_id: Situation.disponivel.id)
      .where("service_start_time > ?", Time.now)
      .as_json(only: [:id, :service_start_time, :service_end_time])

    return response
  end


  # Returns json response to index service_types 
  # @return [Json] response
  def self.index_response
    self.all.as_json(only: [
      :id, :name, :cep, :active, :neighborhood, :phone1
    ], methods: %w(city_hall_name city_name state_name))
  end
  

  # @return [Json] detailed service_type's data
  def complete_info_response
    city = City.find(self.city_id)
    state = city.state
    address = Address.get_address(self.cep)

    return self.as_json(only: [
       :id, :name, :active, :cep, :address_number, :address_complement,
       :phone1, :phone2, :email, :url, :created_at, :updated_at
      ])
      .merge({
        city_hall_name: self.city_hall.name
      })
      .merge({service_types: self.service_types.as_json(only: [
        :id, :description
      ])})
      .merge({
        professionals: self.professionals.simple_index_response
      })
      .merge({city: city.as_json(except: [
        :ibge_code, :state_id, :created_at, :updated_at
      ])})
      .merge({state: state.as_json(except: [
        :ibge_code, :created_at, :updated_at
      ])})
      .merge({address: address.as_json(except: [
        :created_at, :updated_at, :state_id, :city_id
      ])})
  end


  # Get every service_place and its schedules given a service_type
  #
  # @param service_type [ServiceType] specified ServiceType
  # @return [Json] array containing the reponses from get_schedules for every 
  # service_place
  def self.get_schedule_response(service_type)
    service_places = ServicePlace.where(active: true)
      .find(service_type.service_place_ids)

    # Add reponses from get_schedules obtained from every service_place
    # containing the specified service_type 
    response = [].as_json
    for i in service_places
      response << i.get_schedules(service_type.id)
    end

    return response
  end


  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @params permission [String] Permission of current user
  # @return [ActiveRecords] filtered service_places
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
      sortable = [
        "name", 
        "cep", 
        "city_hall_name", 
        "active", 
        "neighborhood"
      ]

      filter = {
        "name" => "name_cont", 
        "active" => "active_eq", 
        "neighborhood" => "neighborhood_cont",
        "cep" => "cep_cont", 
        "city_hall_id" => "city_hall_id_eq", 
        "s" => "s"
      }

    when "adm_prefeitura"
      sortable = [
        "name", 
        "cep",
        "active", 
        "neighborhood"
      ]

      filter = {
        "name" => "name_cont", 
        "active" => "active_eq", 
        "neighborhood" => "neighborhood_cont",
        "cep" => "cep_cont", 
        "role" => "professionals_service_places_role_eq",
        "s" => "s"
      }

    end

    return filter_search_params(params, filter, sortable) 
  end


  # Method surrounding create method for ServicePlace. It associates 
  # the address to the service place given a cep
  def create_service_place
    address = Address.get_address(self.cep)

    if not address.nil?
      self.city_id = address.city_id

      if self.city_hall.city_id != self.city_id
        self.errors["city_hall_id"] << "City hall #{self.city_hall_id} does not "\
          "belong to the given address."

        return false
      end

      self.address_street = address.address
      self.neighborhood = address.neighborhood
    else
      self.errors["cep"] << "#{self.cep} is invalid."
      return false
    end

    yield
  end
end
