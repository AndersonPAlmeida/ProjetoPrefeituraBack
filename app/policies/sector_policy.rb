class SectorPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @citizen = user[0]
      @permission = user[1]

      if @permission == "citizen"
        return scope.all_active_local(@citizen.city_id)
      end

      if (not @citizen.professional.nil?) and @citizen.professional.adm_c3sl?
        return scope.all_active
      else
        return scope.all_active_local(@citizen.city_id)
      end
    end
  end
end
