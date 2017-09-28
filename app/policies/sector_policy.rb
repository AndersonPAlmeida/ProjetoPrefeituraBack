class SectorPolicy < ApplicationPolicy
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
        scope.all_active

      when permission == "adm_prefeitura"
        scope.local_active(city_id)

      else
        nil
      end
    end
  end
end
