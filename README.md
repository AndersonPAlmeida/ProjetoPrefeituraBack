Agendador
=========

O aplicativo Agendador foi desenvolvido para viabilizar a automatização do agendamento dos atendimentos com hora marcada em órgãos públicos, permitindo que uma prefeitura crie, por exemplo, horários de atendimento para médicos em postos de saúde.

Informações
-----------

* Versão rails: 5.0.0
* Versão ruby: 2.3.1
* Versão postgresql: 9.x

## Instalação
### Dependências

##### PostgreSQL
  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
  wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
  sudo apt-get update
  sudo apt-get install postgresql postgresql-contrib

##### Git
  sudo apt-get install git

##### Ruby
  \curl -L https://get.rvm.io | bash -s stable --ruby
  source ~/.rvm/scripts/rvm
  rvm install ruby --latest

##### Rails
  rvm use ruby-2.3.1@rails5.0 --create --default
  gem install rails -v 5.0.0

##### Bundler
  gem install bundler

## Execução (desenvolvimento)
  bundle install
  export AGENDADOR\_API\_DB\_USER="postgres"
  export AGENDADOR\_API\_DB\_PASSWORD="123"
  rake db:create
  rake db:migrate
  rails s

## Workflow de cada atividade

##### 1. Cria branch da atividade ­> #<IDatividade>[\_Resumo\_do\_que\_faz].

##### 2. Desenvolver a atividade

##### 3. Cria teste para a atividade

##### 4. Roda o teste criado sobre a atividade desenvolvida

##### 4.1. Se estiver errado

##### 4.1.1. Volta para o passo 2

##### 4.2. Se estiver certo

##### 4.2.1. git commit ­sm “Explain (the first word must be an infinitive verb) what this commit does”

##### 4.2.2. git push origin <nome\_da\_branch>

##### 4.2.3. Cria merge request para develop

##### 4.3. Registra o resultado da atividade no redmine.

##### Ex: #Issue 1234: Create\_DB\_Schema
