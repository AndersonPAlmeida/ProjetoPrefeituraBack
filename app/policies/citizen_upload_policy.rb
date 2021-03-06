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

class CitizenUploadPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      citizen = user[0]
      permission = Professional.get_permission(user[1])

      return case permission
      when "adm_c3sl"
        scope.all

      when "adm_prefeitura"
        scope.where(citizen_id: citizen.id)

      else
        nil
      end
    end
  end

  def show?
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    return case
    when permission == "adm_c3sl"
      return true

    when permission == "adm_prefeitura"
      return true

    else
      return false
    end
  end

  def create?
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    return case
    when permission == "adm_c3sl"
      return true

    when permission == "adm_prefeitura"
      return (record.citizen_id == citizen.id)

    else
      return false
    end
  end

end
