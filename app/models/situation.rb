class Situation < ApplicationRecord

  # Associations #
  has_many :schedules
  has_many :resource_booking

  # Validations #
  validates_presence_of :description

  # Returns the situation with the description "Agendador" (scheduled)
  # @return [Situation] Returns the situation with the description "Agendador"
  def self.agendado
    where(description: "Agendado").first
  end

  # Returns the situation with the description "Cancelado" (cancelled)
  # @return [Situation] Returns the situation with the description "Cancelado"
  def self.cancelado
    where(description: "Cancelado").first
  end

  # Returns the situation with the description "Cidadão não compareceu" (citizen not attended)
  # @return [Situation] Returns the situation with the description "Cidadão não compareceu"
  def self.citizen_absence
    where(description: "Cidadão não compareceu").first
  end

  # Returns the situation with the description "Professional não compareceu" (professional not attended)
  # @return [Situation] Returns the situation with the description "Professional não compareceu"
  def self.professional_absence
    where(description: "Profissional não compareceu").first
  end

  # Returns the situation with the description "available" (available)
  # @return [Situation] returns the situation with the description "available"
  def self.disponivel
    where(description: "Disponível").first
  end
end
