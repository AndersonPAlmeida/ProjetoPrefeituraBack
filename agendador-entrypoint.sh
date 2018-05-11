#!/usr/bin/env bash
set -e

# /app/bin/rails db:environment:set RAILS_ENV=$RAILS_ENV

if [ "$1" = 'CREATE' ]; then
/app/bin/rake agendador:setup
fi
/app/bin/bundle exec sidekiq -C config/sidekiq.yml >> log/sidekiq.log &
/app/bin/bundle exec rails s -p 3000 -b '0.0.0.0'

exec "$@"
