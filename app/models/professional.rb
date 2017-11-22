class Professional < ApplicationRecord

  # Associations #
  belongs_to :account
  belongs_to :occupation

  has_one :citizen, through: :account
  has_many :professionals_service_places
  has_many :service_places, through: :professionals_service_places

  # Validations #
  validates_presence_of :occupation_id, :account_id

  scope :all_active, -> { 
    where(active: true) 
  }

  scope :local_city, -> (city_id) { 
    joins(:service_places).where("service_places.city_id": city_id).distinct 
  }

  scope :local_service_place, -> (serv_id) { 
    joins(:service_places).where("service_places.id": serv_id).distinct
  }

  delegate :name, to: :citizen
  delegate :cpf, to: :citizen
  delegate :phone1, to: :citizen
  delegate :email, to: :citizen
  delegate :name, to: :occupation, prefix: true

  # Method for getting role from id
  # @param id [Integer/String] permission
  # @return [String] role name
  def self.get_permission(id)
    if /\A\d+\z/.match(id)
      return ProfessionalsServicePlace.find(id).role
    else
      return id
    end
  end

  # Returns json response to index professionals 
  # @return [Json] response
  def self.index_response
    self.all.as_json(only: [:id, :registration, :active], 
                     methods: %w(occupation_name cpf name phone1 email roles_names ))
  end

  # Returns partial info json response to index professionals 
  # @return [Json] response
  def self.simple_index_response
    self.all.as_json(only: :id, methods: %w(name))
  end

  # @return [Json] detailed professional's data
  def complete_info_response
    return self.as_json(only: [:id, :registration, :active])
      .merge({
        occupation: self.occupation.name,
        citizen: self.citizen.partial_info_response,
        service_places: self.professionals_service_places.map { |i| i.info_listing }
      })
  end

  # @return [Array] list of roles
  def roles_ids
    # Array containing every role that the current professional has
    array = self.professionals_service_places.pluck(:id)
    return array
  end

  # @return [Array] list of roles' names
  def roles_names
    # Array containing every role that the current professional has
    array = self.professionals_service_places.pluck(:role)
    return array
  end

  # @return [Boolean] professional is adm_c3sl
  def adm_c3sl?
    self.roles_names.map.include?("adm_c3sl")
  end

  # @return [Boolean] professional is adm_prefeitura
  def adm_prefeitura?
    self.roles_names.include?("adm_prefeitura")
  end

  # @return [Boolean] professional is adm_local
  def adm_local?
    self.roles_names.include?("adm_local")
  end

  # @return [Boolean] professional is atendente
  def atendente?
    self.roles_names.include?("atendente_local")
  end

  # @return [Boolean] professional is tecnico
  def tecnico?
    self.roles_names.include?("responsavel_atendimento")
  end
end
