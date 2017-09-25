class ServicePlace < ApplicationRecord

  # Associations #
  #belongs_to :city
  belongs_to :city_hall
  has_many :professionals_service_places
  has_many :professionals, through: :professionals_service_places
  has_and_belongs_to_many :accounts
  has_and_belongs_to_many :service_types

  # Validations #
  validates_presence_of :address_number
  validates_presence_of :address_street
  validates_presence_of :name
  validates_presence_of :neighborhood

  validates_length_of   :name, maximum: 255
  validates_length_of   :address_number, 
    within: 0..10,
    allow_blank: true

  validates_numericality_of :address_number,
    only_integer: true,
    allow_blank: true

  around_save :create_service_place

  # @return all active service places
  def self.all_active
    ServicePlace.where(active: true)
  end

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

  # Used for returning information required to fill forms in front-end
  #
  # @param user [Array] current_user (session variable)
  # @return [Json] list of reachable service_places
  def self.form_data(user, service_type_ids)
    @citizen = user[0]
    @permission = user[1]

    service_types = ServiceType.where(id: service_type_ids)
    ids = service_types.map { |i| i.service_place_ids }.flatten.uniq!

    st_ids = Hash.new

    service_places = ServicePlace.where(id: ids, active: true)
    response = service_places.as_json(only: [:name, :id])

    for i in service_places
      st_ids[i.id.to_s] = i.service_type_ids
    end

    for i in response
      i["service_types"] = st_ids[i["id"].to_s]
    end

    return response.as_json
  end

  private

  # Method surrounding create method for ServicePlace. It had to be done
  # for associating a City given the CityHall
  def create_service_place
    self.city_id = self.city_hall.city_id
    yield
  end
end
