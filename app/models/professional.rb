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

  # @return [Array] list of roles
  def roles
    self.professionals_service_places.pluck(:role)
  end

  # @return [Boolean] professional is adm_c3sl
  def adm_c3sl?
    self.roles.include?("adm_c3sl")
  end

  # @return [Boolean] professional is adm_prefeitura
  def adm_prefeitura?
    self.roles.include?("adm_prefeitura")
  end

  # @return [Boolean] professional is adm_local
  def adm_local?
    self.roles.include?("adm_local")
  end

  # @return [Boolean] professional is atendente
  def atendente?
    self.roles.include?("atendente_local")
  end

  # @return [Boolean] professional is tecnico
  def tecnico?
    self.roles.include?("responsavel_atendimento")
  end
end
