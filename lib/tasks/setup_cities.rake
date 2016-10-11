# encoding: UTF-8
namespace :agendador do
  require 'csv'

  desc "Popula a tabela de municípios"
  task :setup_cities => :environment do
    puts "Populando tabela de Municípios"

    state_table = Hash.new

    # Do mass insertion for better performance
    City.transaction do
      cities = CSV.read("#{Rails.root}/lib/tasks/agendador_setup_csv/cities.csv")

      # Use dynamic programming for querying each State only once
      cities.each do |city|
        abbreviation = city[0]

        # Replace State abbreviation for state id
        if state_table[abbreviation].nil?
          city[0] = State.where(abbreviation: abbreviation).first.id
          state_table[abbreviation] = city[0]
        else
          city[0] = state_table[abbreviation]
        end
      end

      columns = [:state_id, :ibge_code, :name]

      # import method is provided by activerecord-import gem
      City.import columns, cities, validate: true
    end

    puts "#{City.all.count} registro(s) inserido(s) com sucesso!"
  end
end
