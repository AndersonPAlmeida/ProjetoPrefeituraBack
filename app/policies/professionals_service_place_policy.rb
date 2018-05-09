class ProfessionalsServicePlacePolicy < ApplicationPolicy
  def create_psp?
    citizen = user[0]
    permission = Professional.get_permission(user[1])

    if permission == "citizen"
      return false
    end

    professional = citizen.professional

    service_place = professional.professionals_service_places
      .find(user[1]).service_place

    city_id = service_place.city_id

    roles = [
      "adm_prefeitura", 
      "adm_local", 
      "atendente_local", 
      "responsavel_atendimento"
    ]

    return case
    when permission == "adm_c3sl"
      return ((not record.service_place.nil?) and
        roles.include?(record.role))

    when permission == "adm_prefeitura"
      return ((record.service_place.city_id == city_id) and 
        roles.include?(record.role))

    when permission == "adm_local"
      return ((record.service_place.id == service_place.id) and
        roles.include?(record.role))

    else
      false
    end
  end
end
