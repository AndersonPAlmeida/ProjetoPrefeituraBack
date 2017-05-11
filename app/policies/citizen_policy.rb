class CitizenPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if not user.professional.nil?
        if user.professional.adm_c3sl?
          scope.all_active
        elsif user.professional.adm_prefeitura?
          scope.all_active.where(city_id: user.city_id)
        else
          scope.where(id: user.id)
        end
      else
        scope.all_dependants(user.id)
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
