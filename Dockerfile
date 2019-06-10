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
RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list


RUN apt-get upgrade && apt-get -y update -qq && apt-get install -y -qq libpq-dev wget gnupg software-properties-common curl build-essential --fix-missing --no-install-recommends && apt-get install git && apt-get -y update -qq && apt-get install -y -qq phppgadmin

# Set an environment variable to store where the app is installed to inside of the Docker image.
ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

# This sets the context of where commands will be ran in and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH

COPY . .

RUN gem install rails -v 5.0.0 && gem install bundler && cd bin && bundle install -j 4

EXPOSE 3000:8080
VOLUME ["/app/images/citizens", "/app/images/city_halls", "/data/citizen_upload"]
ENTRYPOINT ["/app/agendador-entrypoint.sh"]
CMD ["CREATE"]
