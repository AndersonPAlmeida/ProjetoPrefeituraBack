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

class CitizenUploadSerializer < ActiveModel::Serializer
  attributes :id,
    :citizen_id,
    :amount,
    :status,
    :status_string,
    :progress,
    :created_at,
    :updated_at

  def status_string
    # Check if status is "Ready to start"
    if object.status == 0
      # return "Ready to start"
      return "Pronto para iniciar"
    # Check if status is "In progress"
    elsif object.status == 1
      # return "In progress"
      return "Em progresso"
    # Check if status is "Completed"
    elsif object.status == 2
      # return "Completed"
      return "Finalizado"
    # Check if status is "Completed with errors"
    elsif object.status == 3
      # return "Completed with errors"
      return "Finalizado com erros"
    end

    # return "Undefined"
    return "Indefinido"
  end
end
