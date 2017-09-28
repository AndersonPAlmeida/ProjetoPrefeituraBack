class SectorPolicy < ApplicationPolicy
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
        scope.all_active

      when permission == "adm_prefeitura"
        scope.local_active(city_id)

      else
        nil
      end
    end
  end
end
