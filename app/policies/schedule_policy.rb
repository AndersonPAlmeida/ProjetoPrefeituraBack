class SchedulePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      citizen = user[0]
      permission = Professional.get_permission(user[1])

      if permission == "citizen"
        return nil
      end

      professional = citizen.professional
      service_place = professional.professionals_service_places
        .find(user[1]).service_place

      city_id = service_place.city_id
      city_hall_id = service_place.city_hall_id
      
      return case permission
      when "adm_c3sl"
        scope.all

      when "adm_prefeitura"
        scope.local_city_hall(city_hall_id)

      when "adm_local"
        scope.local_service_place(service_place.id)

      when "atendente_local"
        scope.local_service_place(service_place.id)

      when "responsavel_atendimento"
        scope.local_service_place(service_place.id).from_professional(professional.id)

      else
        nil
      end
    end
  end


  def update?
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    if permission != "citizen"
      professional = citizen.professional

      service_place = professional.professionals_service_places
        .find(user[1]).service_place

      city_id = service_place.city_id
    end

    return case
    when permission == "adm_c3sl"
      return (record.situation.description == "Disponível")

    when permission == "adm_prefeitura"
      return ((record.service_place.city_hall_id == service_place.city_hall_id) and
              (record.situation.description == "Disponível"))

    when permission == "adm_local"
      return ((record.service_place.id == service_place.id) and
              (record.situation.description == "Disponível"))

    when permission == "atendendente_local" 
      return ((record.service_place.id == service_place.id) and
              (record.situation.description == "Disponível"))

    when permission == "responsavel_atendimento"
      return ((record.service_place.id == service_place.id) and
              (record.shift.professional_performer_id == professional.id)
              (record.situation.description == "Disponível"))

    when permission == "citizen"
      return ((record.situation.description == "Agendado") and
              (record.citizen_id == citizen.id))

    else
      false
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
