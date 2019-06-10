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

class ResourceShiftPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      citizen = user[0]
      permission = Professional.get_permission(user[1])

      if permission == "citizen"
        city_hall_id = CityHall.where(city_id: citizen.city_id).first.id
        service_place_id = nil
      else
        professional = citizen.professional

        city_hall_id = professional.professionals_service_places
          .find(user[1]).service_place.city_hall_id

        service_place_id = professional.professionals_service_places.find(
          user[1]).service_place.id
      end

      resource_type_ids = []
      resource_types = ResourceType.where(city_hall_id: city_hall_id)
      resource_types.each do |rt|
        resource_type_ids << rt.id
      end

      resources = Resource.where(resource_types_id: resource_type_ids.uniq)
      resource_ids = []
      resources.each do |r|
        if permission == "adm_c3sl" || permission == "adm_prefeitura" ||
           r.service_place_id == service_place_id
          resource_ids << r.id
        end
      end

      return case
      when permission == "adm_c3sl"
        scope.all

      else
        scope.where(resource_id: resource_ids.uniq)
      end
    end
  end

  def get_professional_resource_shift?
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    return (permission != "citizen")
  end

  def create?
    return access_policy(user)
  end

  def update?
    return access_policy(user)
  end

  def destroy?
    return access_policy(user)
  end

  def show?
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    if permission == "citizen"
      city_hall_id = CityHall.where(city_id: citizen.city_id).first.id
    else
      professional = citizen.professional
      service_place = professional.professionals_service_places.find(
        params[:permission]).service_place

      city_hall_id = service_place.city_hall_id
    end

    resource_city_hall_id = ResourceType.where(
      id: Resource.where(
        id: record.resource_id
      ).first.resource_types_id
    ).first.city_hall_id

    if permission == "adm_c3sl"
      return true
    end

    return (resource_city_hall_id == city_hall_id)
  end

  def index?
    return access_policy_index(user)
  end

  private

  # Generic method for checking permissions when show/accessing/modifying
  # sectors. It is used for avoiding code repetition in citizen's policy
  # methods.
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

    service_place = professional.professionals_service_places.find(
      user[1]).service_place

    service_place_id = service_place.id

    current_resource_id = record.resource_id

    city_hall_id = service_place.city_hall_id

    resource_service_place_id = Resource.where(
      id: current_resource_id).first.service_place_id

    resource_city_hall_id = ResourceType.where(
                              id: (Resource.where(
                                    id: current_resource_id
                                  ).first.resource_types_id
                              )).first.city_hall_id

    return case
    when permission == "adm_c3sl"
      true
    when permission == "adm_prefeitura"
      (city_hall_id == resource_city_hall_id)
    when permission == "atendente_local"
      (service_place_id == resource_service_place_id)
    when permission == "responsavel_atendimento"
      (service_place_id == resource_service_place_id)
    when permission == "adm_local"
      (service_place_id == resource_service_place_id)
    else
      false
    end
  end

  def access_policy_index(user)
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    if permission == "citizen"
      return false
    end

    professional = citizen.professional

    service_place = professional.professionals_service_places.find(
      user[1]).service_place

    city_hall_id = service_place.city_hall_id

    return case
    when permission == "adm_c3sl"
      true
    when permission == "adm_prefeitura"
      if record.first != nil
        (city_hall_id == record.first.city_hall_id)
      else
        true
      end
    when permission == "adm_local"
      if record.first != nil
        (city_hall_id == record.first.city_hall_id)
      else
        true
      end
    else
      false
    end
  end

end
