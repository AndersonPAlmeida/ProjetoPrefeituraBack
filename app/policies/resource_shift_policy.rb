class ResourceShiftPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      citizen = user[0]
      permission = Professional.get_permission(user[1])

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

      when permission == "citizen"
        scope.local(city_id)
        
      else
        scope.local(service_place_id)

      end
    end
  end

  def create?
    return access_policy_professional(user) 
  end

  def update?
    return access_policy_professional(user) 
  end

  def destroy?
    return access_policy_professional(user) 
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

  def access_policy_professional(user)
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    if permission == "citizen"
      return false
    end

    professional = citizen.professional

    service_place = professional.professionals_service_places
    .find(user[1]).service_place

    service_place_id = service_place.id

    current_resource_id = record.resource_id
    
    city_hall_id = service_place.city_hall_id
    
    resource_service_place_id = Resource.where(id: current_resource_id).first.service_place_id

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
