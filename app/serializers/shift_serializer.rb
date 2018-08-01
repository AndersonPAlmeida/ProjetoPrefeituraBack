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

class ShiftSerializer < ActiveModel::Serializer
  attributes :id, 
    :execution_start_time, 
    :execution_end_time,
    :notes,
    :service_amount

  belongs_to :service_place
  belongs_to :service_type
  has_one :shift, :foreign_key => :next_shift_id, :class_name => "Shift"
  belongs_to :professional, :foreign_key => :professional_responsible_id,
    :class_name => "Professional"
  belongs_to :professional_2, :foreign_key => :professional_performer_id,
    :class_name => "Professional"
end
