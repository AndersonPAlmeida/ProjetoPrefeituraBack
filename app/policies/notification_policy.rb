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

class NotificationPolicy < ApplicationPolicy
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

  # Check if the account that is trying to access a notification is the 
  # same account of the notification
  def access_policy(user)
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    return ((record.account_id == citizen.account_id) or (permission != "citizen"))
  end
end

