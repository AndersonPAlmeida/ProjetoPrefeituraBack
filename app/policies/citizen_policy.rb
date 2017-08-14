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
      when permission == "adm_c3sl" && professional.adm_c3sl?
        scope.all_active.where.not(id: citizen.id)

      when permission == "adm_prefeitura" && professional.adm_prefeitura?
        scope.local_active(city_id).where.not(id: citizen.id)

      when permission == "adm_local" && professional.adm_local?
        scope.local_active(city_id).where.not(id: citizen.id)

      when permission == "atendente_local" && professional.atendente?
        scope.local_active(city_id).where.not(id: citizen.id)

      else
        nil
      end
    end
  end

  def schedule?
    citizen = user[0]
    permission = user[1]

    if permission == "citizen" or citizen.professional.nil?
      return (citizen.id == record.id)
    elsif permission.nil? and not citizen.professional.nil?
      permission = citizen.professional.roles[-1]
    end

    professional = citizen.professional

    city_id = professional.professionals_service_places
      .find_by(role: permission)
      .service_place.city_id

    return case
    when permission == "adm_c3sl" && professional.adm_c3sl?
      return (citizen.id != record.id)

    when permission == "adm_prefeitura" && professional.adm_prefeitura?
      return (citizen.id != record.id) && (city_id == record.city_id)

    when permission == "adm_local" && professional.adm_local?
      return (citizen.id != record.id) && (city_id == record.city_id)

    when permission == "atendente_local" && professional.atendente?
      return (citizen.id != record.id) && (city_id == record.city_id)

    else
      false
    end
  end
end
