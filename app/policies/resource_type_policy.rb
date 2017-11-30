class ResourceTypePolicy < ApplicationPolicy
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
      
      return case
      when permission == "adm_c3sl"
        scope.all

      when permission == "adm_prefeitura"
        scope.local(city_id)

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


    return case
    when permission == "adm_c3sl"
      true
    when permission == "adm_prefeitura" 
      (city_hall_id == record.city_hall_id)      
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

    return case
    when permission == "adm_c3sl"
      true
    when permission == "adm_prefeitura" 
      if record.first != nil
        (city_hall_id == record.first.city_hall_id)  
      else 
        true  
      end
    else
      if record.first != nil
        (city_hall_id == record.first.city_hall_id)  
      else 
        true  
      end 
    end
  end

end
