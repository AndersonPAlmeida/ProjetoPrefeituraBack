class NotificationPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        citizen = user[0]
        permission = Professional.get_permission(user[1])
  
        if permission == "citizen"
          return nil
        end
  
        professional = citizen.professional
  
        service_place= professional.professionals_service_places
          .find(user[1]).service_place
  
        city_hall_id = service_place.city_hall_id
        
        return case permission
        when "adm_c3sl"
          scope.all
  
        when "adm_prefeitura"
          scope.local_city_hall(city_hall_id)
  
        else
          nil
        end
      end
    end
  
    def show?
      return access_policy(user)
    end
  
    def update?
      return access_policy(user)
    end
  
    def create?
      return access_policy(user)
    end

    private
    
    # Check if the account that is trying to access a notification is the same account of the notification
    def access_policy(user)
      citizen = user[0]
      notification_account_id = record.account_id
      permission = Professional.get_permission(user[1])

      return ((notification_account_id == citizen.account_id) or (permission != "citizen"))
    end
  end
  