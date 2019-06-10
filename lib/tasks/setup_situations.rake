# encoding: UTF-8
namespace :agendador do
  require 'csv'

  desc "Popula a tabela de tipos de situação"
  task :setup_situations => :environment do
    puts "Populando tabela de Tipos de Situação"

    # Do mass insertion for better performance
    Situation.transaction do
      situations = CSV.read("#{Rails.root}/lib/tasks/agendador_setup_csv/situations.csv")
      columns = [:description]

      # import method is provided by activerecord-import gem
      Situation.import columns, situations, validate: true
    end

    puts "#{Situation.all.count} registro(s) inserido(s) com sucesso!"
  end
end
