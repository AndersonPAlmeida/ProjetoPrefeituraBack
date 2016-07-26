Agendador
=========

O aplicativo Agendador foi desenvolvido para viabilizar a automatização do agendamento dos atendimentos com hora marcada em órgãos públicos, permitindo que uma prefeitura crie, por exemplo, horários de atendimento para médicos em postos de saúde.

Informações
-----------

* Versão rails: 5.0.0
* Versão ruby: 2.3.1
* Versão PostgreSQL: 9.x

## Instalação
PostgreSQL:
```bash
  $ sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
  $ wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
  $ sudo apt-get update
  $ sudo apt-get install postgresql postgresql-contrib
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
  $ rvm use ruby-2.3.1@rails5.0 --create --default
  $ gem install rails -v 5.0.0
```

Bundler:
```bash
  $ gem install bundler
```

## Execução (desenvolvimento)
```bash
  $ bundle install
  $ export AGENDADOR_API_DB_USER="postgres"
  $ export AGENDADOR_API_DB_PASSWORD="123"
  $ rake db:create
  $ rake db:migrate
  $ rails s
```

## Workflow de cada atividade
1. Criar branch da atividade: #IDatividade[Resumo\_do\_que\_faz].
2. Desenvolver a atividade
3. Criar teste para a atividade
4. Rodar o teste criado sobre a atividade desenvolvida
  1. Se estiver errado  
     Voltar para o passo 2
  2. Se estiver certo  
     git commit -sm “Explain (the first word must be an infinitive verb) what this commit does”  
     git push origin nome\_da\_branch  
     Criar merge request para develop  
  3. Registra o resultado da atividade no redmine. (i.e #Issue 1234: Create\_DB\_Schema
