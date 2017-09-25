source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'

# Use Puma as the app server
gem 'puma', '~> 3.0'

# Provides authentication methods
gem 'devise', '~> 4.3.0'
gem 'devise_token_auth', '~> 0.1.42'

# Provides authorization methods
gem 'pundit', '~> 1.1.0'

# Provides a clean layer between the model and the controller that
# lets us to call to_json or as_json on the ActiveRecord object or
# collection as normal, while outputing our desired API format.
gem 'active_model_serializers', '~> 0.10.0'

# Rack::Attack is a rack middleware to protect your web app from bad
# clients. It allows safelisting, blocklisting, throttling, and tracking
# based on arbitrary properties of the request.
gem 'rack-attack', '~> 5.0.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', '~> 0.4.1'

# Get Brazilian address by zipcode, directly from Correios database.
gem 'correios-cep', '~> 0.6.4'

# Curl for ruby
gem 'curb', '~> 0.9.3'

gem 'activerecord-import', '~> 0.18.3'

gem 'paperclip', '~> 5.0.0'

gem 'ransack'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 9.0.6', platform: :mri
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'minitest-rails', '~> 3.0.0'
  gem 'pry-rails', '~> 0.3.6'
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.0.2'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
