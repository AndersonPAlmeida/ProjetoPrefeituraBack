FROM ruby:2.3.1
LABEL maintainer="horstmannmat <mch15@inf.ufpr.br>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Install dependencies:
# - build-essential: To ensure certain gems can be compiled
# - nodejs: Compile assets
# - libpq-dev: Communicate with postgres through the postgres gem
# - wget curl and gnupg is used to get newest postgres client
# - software-properties-common to use the command lsb_release
#- Get newest postgres client
RUN apt-get -y update -qq && apt-get install -y -qq libpq-dev wget gnupg software-properties-common curl build-essential --fix-missing --no-install-recommends && \
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
apt-get -y update -qq && apt-get install -y -qq postgresql-client-9.6

# Set an environment variable to store where the app is installed to inside of the Docker image.
ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

# This sets the context of where commands will be ran in and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH

COPY . .

RUN gem install rails -v 5.0.0 && \
         gem install bundler && \
         /app/bin/bundle install -j 4

EXPOSE 3000
VOLUME ["/app/images/citizens", "/app/images/city_halls", "/data/citizen_upload"]
ENTRYPOINT ["/app/agendador-entrypoint.sh"]
CMD ["CREATE"]
