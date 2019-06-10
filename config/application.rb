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

require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Correios::CEP.configure do |config|
  config.log_enabled = false   # It disables the log
  config.logger = Rails.logger # It uses Rails logger
end

module BackEndServer
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Set time zone
    config.time_zone = 'Brasilia'

    # Configure path for custom validators
    config.autoload_paths += %W["#{config.root}/app/validators/"]

    # Use devise in PT-BR
    config.i18n.default_locale = :'pt-BR'

    # Configure minitest without spec and no fixture
    config.generators do |g|
      g.test_framework :minitest, fixture: false
    end

    # Allows GET, POST, PUT, DELETE or OPTIONS requests from specified origins on any resource.
    config.middleware.insert_before 0, Rack::Cors do
      allow do

        # Specify which origins should be allowed to make requests (e.g. agendador.c3sl.ufpr.br)
        origins '*'
        resource '*', :headers => :any,
          :methods => [:get, :post, :put, :delete, :options],
          :expose => ['access-token', 'expiry', 'token-type', 'uid', 'client']
      end
    end

    # Protect the API from DDoS, brute force attacks, hammering...
    config.middleware.use Rack::Attack

    config.middleware.use ActionDispatch::Flash
  end
end
