class CitizenPolicy < ApplicationPolicy
  class Scope < Scope

    def verify_professional(result, condition)
      if @is_professional and condition
        return result
      else
        return scope.where(id: citizen.id)
      end
    end

    def resolve
      citizen = user[0]
      permission = user[1]

      if permission == "citizen"
        return scope.all_dependants(citizen.id)
      end

      @is_professional = citizen.professional.nil? == false

      case permission
        when "adm_c3sl"
          return verify_professional(
            scope.all_active, 
            citizen.professional.adm_c3sl?
          )

        when "adm_prefeitura"
          return verify_professional(
            scope.all_active.where(city_id: citizen.city_id), 
            citizen.professional.adm_prefeitura?
          )

        else
          return scope.where(id: citizen.id)
      end
    end

  end

  def index?
    if not user.professional.nil?
      if user.professional.adm_c3sl? or
          user.professional.adm_prefeitura?
        return true
      end
    end

    return false
  end
end
