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

require 'sidekiq'

Sidekiq.configure_server do |config|
	config.redis = {
		url: 'redis://agendador-redis:6379',
		password: ENV.fetch("AGENDADOR_REDIS_PASSWORD") { "123mudar" }
	}
end

Sidekiq.configure_client do |config|
	config.redis = {
		url: 'redis://agendador-redis:6379',
		password: ENV.fetch("AGENDADOR_REDIS_PASSWORD") { "123mudar" }
	}
end
