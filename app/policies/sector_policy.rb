class SectorPolicy < ApplicationPolicy
  class Scope < Scope

    def verify_professional(result, condition)
      if @is_professional and condition
        return result
      else
        return scope.all_active_local(@citizen.city_id)
      end
    end

    def resolve
      @citizen = user[0]
      @permission = user[1]

      if @permission == "citizen"
        return scope.all_active_local(@citizen.city_id)
      end

      @is_professional = @citizen.professional.nil? == false

      return verify_professional(
        scope.all_active,
        @citizen.professional.adm_c3sl?
      )
    end

  end
end
