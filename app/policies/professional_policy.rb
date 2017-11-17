class ProfessionalPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      citizen = user[0]
      permission = Professional.get_permission(user[1])

      if permission == "citizen"
        return nil
      end

      professional = citizen.professional

      service_place = professional.professionals_service_places
        .find(user[1]).service_place

      city_id = service_place.city_id
      
      return case permission
      when "adm_c3sl"
        scope.all_active.where.not(id: citizen.professional.id)

      when "adm_prefeitura"
        ids = scope.where(professionals_service_places: {role: "adm_c3sl"})
          .includes(:professionals_service_places).pluck(:id)

        ids << citizen.professional.id
        scope.all_active.local_city(city_id).where.not(id: ids)

      when "adm_local"
        scope.all_active.local_service_place(service_place.id)
          .where.not(id: citizen.professional.id)

      else
        nil
      end
    end
  end

  def show?
    return access_policy(user)
  end


  def deactivate?
    return access_policy(user)
  end

  def update?
    return access_policy(user)
  end

  private
  
  # Generic method for checking permissions when show/accessing/modifying 
  # professionals. It is used for avoiding code repetition in professional's policy
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

    service_place= professional.professionals_service_places
      .find(user[1]).service_place

    city_id = service_place.city_id

    return case
    when permission == "adm_c3sl"
      return (citizen.id != record.citizen.id)

    when permission == "adm_prefeitura"
      return (citizen.id != record.citizen.id) && 
        (record.service_places.pluck(:city_id).include? city_id) && 
        (not record.adm_c3sl?)

    when permission == "adm_local"
      return (citizen.id != record.citizen.id) && 
        (record.service_places.pluck(:id).include? service_place.id) && 
        (not record.adm_c3sl?)

    else
      false
    end
  end
end
