# This file is part of Agendador.
#
# Agendador is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Agendador is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Agendador.  If not, see <https://www.gnu.org/licenses/>.

class Situation < ApplicationRecord

  # Associations #
  has_many :schedules
  has_many :resource_booking

  # Validations #
  validates_presence_of :description

  # Returns the situation with the description "Agendador" (scheduled)
  # @return [Situation] situation with the description "Agendador"
  def self.agendado
    where(description: "Agendado").first
  end

  # Returns the situation with the description "Cancelado" (cancelled)
  # @return [Situation] situation with the description "Cancelado"
  def self.cancelado
    where(description: "Cancelado").first
  end

  # Returns the situation with the description "Cidadão não compareceu" (citizen not attended)
  # @return [Situation] situation with the description "Cidadão não compareceu"
  def self.citizen_absence
    where(description: "Cidadão não compareceu").first
  end

  # Returns the situation with the description "Professional não compareceu" (professional not attended)
  # @return [Situation] situation with the description "Professional não compareceu"
  def self.professional_absence
    where(description: "Profissional não compareceu").first
  end

  # Returns the situation with the description "available" (available)
  # @return [Situation] situation with the description "available"
  def self.disponivel
    where(description: "Disponível").first
  end

  # Situations where the citizen showed up
  def self.compareceu
    where(description: [
      "Atendimento realizado", 
      "Cidadão compareceu com atraso", 
      "Profissional compareceu com atraso"
    ])
  end 
end
