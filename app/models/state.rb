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

class State < ApplicationRecord

  # Associations #
  has_many :cities

  # Validations #
  validates_presence_of :ibge_code, :name, :abbreviation
  validates_length_of   :ibge_code, :name, minimum: 2, maximum: 255
  validates_length_of   :abbreviation, minimum: 2, maximum: 2
end
