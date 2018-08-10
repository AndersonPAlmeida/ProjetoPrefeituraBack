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

class ServicePlacePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      citizen = user[0]
      permission = Professional.get_permission(user[1])

      if permission == "citizen"
        return nil
      end

      professional = citizen.professional

      service_place= professional.professionals_service_places
        .find(user[1]).service_place

      city_hall_id = service_place.city_hall_id
      
      return case permission
      when "adm_c3sl"
        scope.all

      when "adm_prefeitura"
        scope.local_city_hall(city_hall_id)

      else
        nil
      end
    end
  end

  def show?
    return access_policy(user)
  end

  def update?
    return access_policy(user)
  end

  def create?
    return access_policy(user)
  end

  private
  
  # Generic method for checking permissions when show/accessing/modifying 
  # service places. It is used for avoiding code repetition in service 
  # place's policy methods.
  #
  # @param user [Array] current citizen and the permission provided
  # @return [Boolean] true if allowed, false otherwise
  def access_policy(user)
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    if permission == "citizen"
      return false
    end

    professional = citizen.professional

    service_place = professional.professionals_service_places
      .find(user[1]).service_place

    city_hall_id = service_place.city_hall_id

    return case
    when permission == "adm_c3sl"
      return true

    when permission == "adm_prefeitura"
      return (record.city_hall_id == city_hall_id)

    else
      false
    end
  end

end
