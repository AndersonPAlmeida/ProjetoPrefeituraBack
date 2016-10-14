# encoding: UTF-8
namespace :agendador do
  require 'csv'

  desc "Popula o banco de dados do Agendador"
  task :setup => [:drop_and_create, :environment, :init, :setup_situations,
                  :setup_states, :setup_cities] do
 
    if not Rails.env.production?
      Rake::Task['agendador:setup_examples'].invoke
    end

    ActiveRecord::Base.connection.disconnect!

    puts "O banco de dados do Agendador foi inicializado com sucesso!"
  end
# ======== Task: drop_and_create ===============================================
  desc "Cria ou limpa o db"
  task :drop_and_create do
    puts "Resetando o banco e executando as migrações do banco de dados"
    Rake::Task['db:migrate:reset'].invoke
    puts "Migrações executadas com sucesso!"
  end

# ======== Task: init ==========================================================
  desc "Inicializa o banco de dados do Agendador"
  task :init => :environment do
    if Rails.env.production?
      ActiveRecord::Base.establish_connection(:production)
    elsif Rails.env.test?
      ActiveRecord::Base.establish_connection(:test)
    else
      ActiveRecord::Base.establish_connection(:development)
    end
  end
end
