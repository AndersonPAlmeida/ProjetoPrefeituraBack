class CitizenUploadPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      citizen = user[0]
      permission = Professional.get_permission(user[1])

      return case permission
      when "adm_c3sl"
        scope.all

      when "adm_prefeitura"
        scope.where(citizen_id: citizen.id)

      else
        nil
      end
    end
  end

  def show?
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    return case
    when permission == "adm_c3sl"
      return true

    when permission == "adm_prefeitura"
      return true

    else
      return false
    end
  end

  def create?
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    return case
    when permission == "adm_c3sl"
      return true

    when permission == "adm_prefeitura"
      return (record.citizen_id == citizen.id)

    else
      return false
    end
  end

end
