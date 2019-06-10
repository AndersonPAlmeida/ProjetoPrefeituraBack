# This file is part of Agendador.
#
# Agendador is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Agendador is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Agendador.  If not, see <https://www.gnu.org/licenses/>.

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
