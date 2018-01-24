class SolicitationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      citizen = user[0]
      permission = Professional.get_permission(user[1])

      if permission == "citizen"
        return nil
      end
      
      return case permission
      when "adm_c3sl"
        scope.all
      else
        nil
      end
    end
  end

  def show?
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    if permission == "citizen"
      return false
    end

    return case
    when permission == "adm_c3sl"
      return true

    else
      false
    end
  end
end
