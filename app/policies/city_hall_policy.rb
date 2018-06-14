class CityHallPolicy < ApplicationPolicy
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

    else
      false
    end
  end

  def picture?
    return picture_access_policy(user)
  end

  def destroy?
    permission = Professional.get_permission(user[1])

    if permission == "adm_c3sl"
      return true
    end

    return false
  end

  private

  # Method for checking permissions when showing city hall picture
  def picture_access_policy(user)
    citizen = user[0]
    permission = Professional.get_permission(user[1])
    professional = citizen.professional

    service_place = professional.professionals_service_places
      .find(user[1]).service_place

    city_hall_id = service_place.city_hall_id

    return case
    when permission == "adm_c3sl"
      return true

    else
      return (record.id == city_hall_id)
    end
  end

  # Generic method for checking permissions when show/accessing/modifying
  # city halls. It is used for avoiding code repetition in city
  # hall's policy methods.
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
      return (record.id == city_hall_id)

    else
      false
    end
  end
end
