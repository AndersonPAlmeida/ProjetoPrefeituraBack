# encoding: UTF-8
namespace :agendador do
  require 'csv'

  desc "Popula a tabela de Unidades da Federação"
  task :setup_states => :environment do
    puts "Populando tabela de Unidades da Federação"

    # Do mass insertion for better performance
    State.transaction do
      states = CSV.read("#{Rails.root}/lib/tasks/agendador_setup_csv/states.csv")
      columns = [:ibge_code, :name, :abbreviation]

      # import method is provided by activerecord-import gem
      State.import columns, states, validate: true
    end

    puts "#{State.all.count} registro(s) inserido(s) com sucesso!"
  end
end
