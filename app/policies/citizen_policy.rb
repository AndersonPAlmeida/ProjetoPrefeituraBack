class CitizenPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      citizen = user[0]
      permission = user[1]

      if permission == "citizen" or citizen.professional.nil?
        return nil
      elsif permission.nil? and not citizen.professional.nil?
        permission = citizen.professional.roles[-1]
      end

      professional = citizen.professional

      city_id = professional.professionals_service_places
        .find_by(role: permission)
        .service_place.city_id
      
      return case
      when permission == "adm_c3sl"
        scope.all_active.where.not(id: citizen.id)

      when permission == "adm_prefeitura"
        scope.local_active(city_id).where.not(id: citizen.id)

      when permission == "adm_local"
        scope.local_active(city_id).where.not(id: citizen.id)

      when permission == "atendente_local"
        scope.local_active(city_id).where.not(id: citizen.id)

      else
        nil
      end
    end
  end

  def show?
    return access_policy(user, false)
  end

  def deactivate?
    return access_policy(user, false)
  end

  def show_dependants?
    return access_policy(user, (user[0].id == record.id))
  end

  def create_dependants?
    return access_policy(user, (user[0].id == record.id))
  end

  def schedule?
    return access_policy(user, ((user[0].id == record.id) || 
                                (record.responsible_id == user[0].id)))
  end

  private
  
  # Generic method for checking permissions when show/accessing/modifying 
  # citizens. It is used for avoiding code repetition in citizen's policy
  # methods.
  #
  # @param user [Array] current citizen and the permission provided
  # @param condition [Boolean] condition returned when the permission is "citizen"
  # @return [Boolean] true if allowed, false otherwise
  def access_policy(user, condition)
    citizen = user[0]
    permission = user[1]

    if permission == "citizen" or citizen.professional.nil?
      return condition 
    elsif permission.nil? and not citizen.professional.nil?
      permission = citizen.professional.roles[-1]
    end

    professional = citizen.professional

    city_id = professional.professionals_service_places
      .find_by(role: permission)
      .service_place.city_id

    return case
    when permission == "adm_c3sl"
      return (citizen.id != record.id)

    when permission == "adm_prefeitura"
      return (citizen.id != record.id) && (city_id == record.city_id)

    when permission == "adm_local"
      return (citizen.id != record.id) && (city_id == record.city_id)

    when permission == "atendente_local"
      return (citizen.id != record.id) && (city_id == record.city_id)

    else
      false
    end
  end

end
