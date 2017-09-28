class ServiceType < ApplicationRecord

  # Associations #
  belongs_to :sector
  has_and_belongs_to_many :service_places

  # Validations #
  validates_presence_of :description
  validates_inclusion_of :active, in: [true, false]

  # @return all active service types
  def self.all_active
    ServiceType.where(active: true)
  end

  # Response used to fill the list of service_types in the scheduling process,
  # consists of all the service_type from a given sector
  #
  # @param sector_id [String] the id of the specified sector
  # @return [Json] reponse with list of service_types
  def self.schedule_response(sector_id)
    response = ServiceType.where(sector_id: sector_id, active: true)
      .as_json(only: [:id, :active, :description])

    # Add number of available schedules for each service_type
    for i in response 
      i["schedules"] = Schedule.where(shifts: {service_type_id: i["id"]})
        .includes(:shift)
        .where(situation_id: Situation.disponivel)
        .count
    end

    return response
  end

  # Used for returning information required to fill forms in front-end
  #
  # @return [Json] list of reachable service_types
  def self.form_data(sector_ids)
    response = ServiceType.where(sector_id: sector_ids, active: true)
      .as_json(only: [:description, :id, :sector_id])

    return response
  end
end
