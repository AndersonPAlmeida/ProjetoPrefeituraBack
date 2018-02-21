class ResourcePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      citizen = user[0]
      permission = Professional.get_permission(user[1])

      if permission == "citizen"
        return nil
      end

      professional = citizen.professional

      city_id = professional.professionals_service_places
        .find(user[1]).service_place.city_id

      service_place_id = professional.professionals_service_places
        .find(user[1]).service_place.id  

      return case
      when permission == "adm_c3sl"
        scope.all

      when permission == "adm_prefeitura"
        scope.local(city_id)

      when permission == "adm_local"
        scope.local(service_place_id)

      else
        nil
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

    service_place = professional.professionals_service_places
    .find(user[1]).service_place

    city_hall_id = service_place.city_hall_id

    if (record!= nil)
      city_hall_id_resource = 
        CityHall.where(id:ResourceType.where(id:record.resource_types_id).first.city_hall_id).first.id
    else 
      city_hall_id_resource = nil 
    end

    return case
    when permission == "adm_c3sl"
      true
    when permission == "adm_prefeitura" 
      (city_hall_id == city_hall_id)  
    when permission == "adm_local" 
      (city_hall_id == city_hall_id)     
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

    service_place = professional.professionals_service_places
    .find(user[1]).service_place

    city_hall_id = service_place.city_hall_id

    if (record.first != nil)
      city_hall_id_resource = 
        CityHall.where(id:ResourceType.where(id:record.first.resource_types_id).first.city_hall_id).first.id
    else 
      city_hall_id_resource = nil 
    end

    return case
    when permission == "adm_c3sl"
      true
    when permission == "adm_prefeitura" 
      if record.first != nil
        (city_hall_id == city_hall_id_resource)   
      else 
        true
      end
    else
      if record.first != nil
        (service_place.id == record.first.service_place_id)
        (city_hall_id == city_hall_id_resource)   
      else 
        true
      end   
    end
  end

end
