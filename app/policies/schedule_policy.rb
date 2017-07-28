class SchedulePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  # Check if user who is confirming schedule is allowed to schedule
  # for the given citizen
  def permitted?
    @citizen = user[0]
    @permission = user[1]

    if record.target_citizen_id.nil?
      record.target_citizen_id = @citizen.id
    end

    citizen = Citizen.find(record.target_citizen_id)

    if @permission == "citizen" or @citizen.professional.nil?
      dependants_ids = Citizen.where(responsible_id: @citizen.id).pluck(:id)

      # Return false if the target is neither the current citizen nor one 
      # of his dependants
      return (citizen.id == @citizen.id or (dependants_ids.include? citizen.id))
    elsif @permission.nil? and not @citizen.professional.nil?
      @permission = @citizen.professional.roles[-1]
    end


    case @permission
    when "adm_c3sl"
      return @citizen.professional.adm_c3sl?
    when "adm_prefeitura"
      return @citizen.professional.adm_prefeitura? and 
        citizen.city_id == @citizen.city_id 
    end

    return false
  end

  # Check if the citizen which the schedule is being confirmed for has
  # no other schedule with conflicting starting/ending time
  def no_conflict?
    return true
  end
end
