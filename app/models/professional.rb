class Professional < ApplicationRecord

  # Associations #
  belongs_to :account
  belongs_to :occupation

  has_one :citizen, through: :account
  has_many :professionals_service_places
  has_many :service_places, through: :professionals_service_places

  # Validations #
  validates_presence_of :occupation_id, :account_id

  # @return all active professionals
  def self.all_active
    Professional.where(active: true)
  end

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

  # @return [Array] list of roles
  def roles
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
