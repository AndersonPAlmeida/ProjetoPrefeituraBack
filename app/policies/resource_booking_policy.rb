class ResourceBookingPolicy < ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  class Scope < Scope
    def resolve
      citizen = user[0]
      permission = Professional.get_permission(user[1])
      professional = citizen.professional

      city_id = professional.professionals_service_places.find(
        user[1]).service_place.city_id

      service_place = professional.professionals_service_places.find(
        user[1]).service_place

      city_hall_id = service_place.city_hall_id

      service_place_ids = []

      if permission != "citizen"
        if permission == "adm_prefeitura"
          # User can get all bookings of the city
          service_place_id = ServicePlace.where(city_hall_id: city_hall_id)
        else
          # User can get all bookings of the city
          service_place_id = [service_place]
        end

        service_place_id.each do |sp|
          service_place_ids << sp.id
        end
      end

      return case
      when permission == "adm_c3sl"
        scope.all
      when permission == "adm_prefeitura"
        scope.where(service_place_id: service_place_ids.uniq)
      when permission == "citizen"
        scope.where(citizen_id: citizen.id)
      else
        scope.where(service_place_id: service_place_ids.uniq)
      end
    end
  end

  def show?
    return access_policy(user)
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
      city_hall_id = CityHall.where(city_id: citizen.city_id).first.id
    else
      professional = citizen.professional

      service_place = professional.professionals_service_places.find(
        user[1]).service_place

      city_hall_id = service_place.city_hall_id
    end

    resource_city_hall_id = ServicePlace.where(
      id: record.service_place_id).first.city_hall_id

    return case
    when permission == "adm_c3sl"
      true
    when permission == "adm_prefeitura"
      (city_hall_id == resource_city_hall_id)
    when permission == "citizen"
      (record.citizen_id == citizen.id)
    else
      (service_place.id == record.service_place_id)
    end
  end

end
