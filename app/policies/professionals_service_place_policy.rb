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

class ProfessionalsServicePlacePolicy < ApplicationPolicy
  def create_psp?
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    if permission == "citizen"
      return false
    end

    professional = citizen.professional

    service_place = professional.professionals_service_places
      .find(user[1]).service_place

    city_id = service_place.city_id

    roles = [
      "adm_prefeitura", 
      "adm_local", 
      "atendente_local", 
      "responsavel_atendimento"
    ]

    return case
    when permission == "adm_c3sl"
      return ((not record.service_place.nil?) and
        roles.include?(record.role))

    when permission == "adm_prefeitura"
      return ((record.service_place.city_id == city_id) and 
        roles.include?(record.role))

    when permission == "adm_local"
      return ((record.service_place.id == service_place.id) and
        roles.include?(record.role))

    else
      false
    end
  end
end
