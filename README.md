Agendador
=========

O aplicativo Agendador foi desenvolvido para viabilizar a automatização do agendamento dos atendimentos com hora marcada em órgãos públicos, permitindo que uma prefeitura crie, por exemplo, horários de atendimento para médicos em postos de saúde.

Informações
-----------

* Versão rails: 5.0.0
* Versão ruby: 2.3.1
* Versão PostgreSQL: 9.x

## Docker
Instale o [docker-ce](https://docs.docker.com/install/) e configure o dns em `/etc/docker/daemon.json`
```
{
   "dns": [ "200.17.202.3"]
}
```

```
Aviso

Este Dockerfile deve ser apenas usado em development

```
```bash
  $ git clone git@gitlab.c3sl.ufpr.br:agendador/Back-end-server.git
  $ sudo docker-compose up
```

## Instalação
PostgreSQL:
```bash
  $ sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
  $ wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
  $ sudo apt-get update
  $ sudo apt-get install postgresql postgresql-contrib
```

Configuração PostgreSQL: (O usuário criado serve apenas para "development" e "test", em "production" é utilizado $AGENDADOR\_API\_DB\_USER com senha $AGENDADOR\_API\_DB\_PASSWORD)
```bash
  $ sudo su - postgres
  $ psql
  # \password postgres
  # create role agendador with password '123mudar';
  # alter role agendador with createdb;
  # alter role agendador with login;
  # alter role agendador with createrole;
  # \q
```

Git:
```bash
  $ sudo apt-get install git
```

Ruby:
```bash
  $ curl -L https://get.rvm.io | bash -s stable --ruby
  $ source ~/.rvm/scripts/rvm
  $ rvm install ruby --latest
```

Rails:
```bash
  $ gem install rails -v 5.0.0
  $ rvm use ruby-2.3.1@rails5.0 --create --default
```

Bundler:
```bash
  $ gem install bundler
```

## Execução (desenvolvimento)
```bash
  $ bundle install
  $ export POSTGRES_HOST=localhost
  $ rake db:migrate
  $ rake agendador:setup
  $ rails s
```

## Requests (Postman)
https://www.getpostman.com/collections/0f51e86e6e65c15baf9d

## Workflow de cada atividade
1. Criar branch da atividade: Issue\_x, onde x corresponde ao ID da issue no projeto AGILE
2. Desenvolver a atividade
3. Criar teste para a atividade
4. Rodar o teste criado sobre a atividade desenvolvida
  1. Se estiver errado:
     Voltar para o passo 2
  2. Se estiver certo:  
     bin/retab  
     git commit -sm “Explain (the first word must be an infinitive verb) what this commit does”  
     git push origin nome\_da\_branch  
     Criar merge request para develop  
  3. Registra o resultado da atividade no projeto AGILE.
