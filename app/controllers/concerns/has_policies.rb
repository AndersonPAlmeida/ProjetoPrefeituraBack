module HasPolicies
  extend ActiveSupport::Concern

  included do
    rescue_from Pundit::NotAuthorizedError, with: :policy_error_description
  end

  # Rescue Pundit exception for providing more details in reponse
  def policy_error_description(exception)

    # Get SchedulePolicy method's name responsible for raising exception 
    @policy_name = exception.message.split(' ')[3]
  end
end
