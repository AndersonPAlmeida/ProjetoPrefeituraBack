class SchedulePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  # TODO: Check for permissions between schedule and citizen being scheduled.
  # It involves either the future relation between schedule and citizen or 
  # simply the location related to the shift which the schedule is related to.
  # (record.shift.service_place.city_id)
  #
  # Check if user who is confirming schedule is allowed to schedule
  # for the given citizen
  def permitted?
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    if record.target_citizen_id.nil?
      record.target_citizen_id = citizen.id
    end

    # Citizen which a schedule is being scheduled for
    schedulee = Citizen.find(record.target_citizen_id)

    if permission == "citizen"
      dependants_ids = Citizen.where(responsible_id: citizen.id).pluck(:id)

      # Return false if the target is neither the current citizen nor one 
      # of his dependants
      return (schedulee.id == citizen.id or (dependants_ids.include?(schedulee.id)))
    end


    return case permission
    when "adm_c3sl"
      true

    when "adm_prefeitura"
      (schedulee.city_id == citizen.city_id)

    when "atendente_local"
      (schedulee.city_id == citizen.city_id)

    else
      false
    end
  end

  # Check if the citizen which the schedule is being confirmed for has
  # no other schedule with conflicting starting/ending time
  def no_conflict?
    citizen = user[0]

    if record.target_citizen_id.nil?
      record.target_citizen_id = citizen.id
    end

    schedulee = Citizen.find(record.target_citizen_id)

    # Schedules that the citizen already has
    citizen_s_schedules = Schedule.where(citizen_id: schedulee.id)
      .where(situation_id: Situation.agendado.id)

    for i in citizen_s_schedules

      # If there is any conflict, then the citizen shouldn't be able to schedule
      if (record.service_start_time..record.service_end_time)
        .overlaps?(i.service_start_time..i.service_end_time)

        return false
      end
    end

    return true
  end
end
