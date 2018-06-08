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