FROM ruby:2.3.1
MAINTAINER horstmannmat <mch15@inf.ufpr.br>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

#Install apt-utils to prevent warning messages
RUN apt-get -y update -qq && apt-get install -y -qq apt-utils

# Install dependencies:
# - build-essential: To ensure certain gems can be compiled
# - nodejs: Compile assets
# - libpq-dev: Communicate with postgres through the postgres gem
# - wget curl and gnupg is used to get newest postgres client
# - software-properties-common to use the command lsb_release
RUN apt-get install -y -qq libpq-dev wget gnupg software-properties-common curl build-essential --fix-missing --no-install-recommends

#Get newest postgres client
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get -y update -qq && apt-get install -y -qq postgresql-client-9.6

# Set an environment variable to store where the app is installed to inside of the Docker image.
ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

# This sets the context of where commands will be ran in and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH

COPY . .


RUN gem install rails -v 5.0.0 && \
         gem install bundler && \
         bundle install -j 4
         # rake db:migrate && \
         # rake agendador:setup

# Expose a volume so that apache2 will be able to read in assets in production.
RUN echo "#! /bin/bash" > /app/exec.sh &&\
echo "rake agendador:setup" >> /app/exec.sh && \
echo "rails s -b 0.0.0.0" >> /app/exec.sh  && \
chmod +x /app/exec.sh


VOLUME ["$INSTALL_PATH/public"]

EXPOSE 3000

CMD ["/bin/bash", "-c", "/app/exec.sh"]
