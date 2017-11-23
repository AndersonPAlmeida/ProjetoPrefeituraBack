# encoding: UTF-8
namespace :agendador do
  require 'csv'

  # Diretório onde estão contidos os arquivos CSV
  # em relação à raiz da aplicação.
  # csv_basedir = Rails.root.join('lib/tasks/agendador_setup_csv/')

  desc "Popula exemplos de Prefeitura, Locais de Atendimento,
    Tipos de Atendimento, Profissionais e Cidadãos"
  task :setup_examples => :environment do
    puts "Inserindo exemplos"
    printf "Inserindo Prefeituras..."

    city_halls = []
    sectors = []
    service_types = []
    service_places = []
    occupations = []
    citizens = {}
    accounts = {}
    professionals = {}
    shifts=[]
    situations=[]
    schedules=[]

    city_halls[0] = CityHall.create({ # CityHall Curitiba
      name: "Prefeitura Municipal de Curitiba",
      cep: "80530-908",
      neighborhood: "Centro Cívico",
      address_street: "Av. Cândido de Abreu",
      address_number: 23,
      city: City.where(:name => "Curitiba").first,
      schedule_period: 90,
      phone1: "156",
      description: "O aplicativo Agendador foi desenvolvido para viabilizar a automatização do agendamento dos atendimentos com hora marcada em órgãos públicos, permitindo que uma prefeitura crie, por exemplo, horários de atendimento para médicos em postos de saúde.",
      block_text: "Para realizar seu agendamento, entre em contato com a prefeitura.",
      active: true,
      url: "",
    })
    city_halls[1] = CityHall.create({ # CityHall São José dos Pinhais
      name: "Prefeitura Municipal de São José dos Pinhais",
      cep: "83040-420",
      neighborhood: "Affonso Pena",
      address_street: "R. José Claudino Barbosa",
      address_number: 2407,
      city: City.where(:name => "São José dos Pinhais").first,
      schedule_period: 72,
      phone1: "156",
      description: "O aplicativo Agendador foi desenvolvido para viabilizar a automatização do agendamento dos atendimentos com hora marcada em órgãos públicos, permitindo que uma prefeitura crie, por exemplo, horários de atendimento para médicos em postos de saúde.",
      block_text: "Para realizar seu agendamento, entre em contato com a prefeitura.",
      active: true,
      url: "",
    })
    puts "OK!"

    printf "Inserindo Cargos..."
    for i in (0..4) do # Occupations A, B, C, D e E
      occupations[i] = Occupation.create({
        name: "Cargo " + (97+i).chr,
        description: "Descrição do cargo " + (97+i).chr,
        city_hall: city_halls[i%2],
        active: true
      })
    end
    puts "OK!"

    printf "Inserindo Setores..."
    sectors[0] = Sector.create({ # Sector Ambiental
      name: "Setor Ambiental",
      description: "Responsável por resolver assuntos relacionados ao meio ambiente",
      schedules_by_sector: 2,
      city_hall: city_halls[0],
      cancel_limit: 3,
      blocking_days: 20,
      absence_max: 2,
      active: true
    })
    sectors[1] = Sector.create({ # Sector Rural
      name: "Setor Agropecuário",
      description: "Abrange atendimentos relacionados a produção agropecuária",
      schedules_by_sector: 3,
      city_hall: city_halls[1],
      cancel_limit: 3,
      blocking_days: 20,
      absence_max: 2,
      active: true
    })
    sectors[2] = Sector.create({ # Sector Saude
      name: "Setor da Saúde",
      description: "Relacionados a atividades de produção, distribuição e consumo de bens e serviços, cujos objetivos principais ou exclusivos são promover a saúde de indivíduos ou grupos de população",
      schedules_by_sector: 3,
      city_hall: city_halls[0],
      cancel_limit: 3,
      blocking_days: 20,
      absence_max: 3,
      active: true
    })
    puts "OK!"

    printf "Inserindo Tipos de Atendimentos..."
    service_types_array = ['Consulta ambulatorial', 'Clareamento', 
      'Consulta pediátrica', 'Consultoria aduaneira', 'Consultoria rural']
    service_types_array.each_with_index do |st, i|
      service_types[i] = ServiceType.create({ #Service Types from array
        description: st,
        sector: sectors[i%3],
        active: true
      })
    end
    puts "OK!"

    printf "Inserindo locais de atendimento gerais para cada prefeitura"
    city_halls.each_with_index do |ch, i| # City Hall's adminsitration places
      service_places[i] = ServicePlace.create({
        name: ch.name,
        cep: ch.cep,
        neighborhood: ch.neighborhood,
        address_street: ch.address_street,
        address_number: ch.address_number,
        active: true,
        city_hall: ch
      })
    end
    puts "OK!"

    printf "Inserindo Local de Atendimento SMS..."
    service_places << ServicePlace.create({ # ServicePlace SMS in Curitiba
      name: "SMS - Secretaria Municipal da Saúde",
      cep: "80035-010",
      neighborhood: "Cabral",
      address_street: "R. Bom Jesus",
      address_number: 52,
      active: true,
      city_hall: city_halls[0]
    })
    service_places[2].service_types << service_types[0] # Serv_type ambulat.
    service_places[2].service_types << service_types[2] # Serv_type pediatrica

    service_places << ServicePlace.create({ # ServicePlace Odont in Sao J.
      name: "Clínica de odontologia",
      cep: "83065-180",
      neighborhood: "Vila Ina",
      address_street: "R. Tavares de Lyra",
      address_number: 78,
      active: true,
      city_hall: city_halls[1]
    })
    service_places[3].service_types << service_types[0] # Serv_type ambulat.
    service_places[3].service_types << service_types[1] # Serv_type Claream.

    service_places << ServicePlace.create({ # ServicePlace Centro in Curitiba
      name: "Centro de apoio ao empreendimento",
      cep: "80035-010",
      neighborhood: "Cabral",
      address_street: "R. Bom Jesus",
      address_number: 16,
      active: true,
      city_hall: city_halls[0]
    })
    service_places[4].service_types << service_types[3] # Serv_type Cons. Aduan.
    service_places[4].service_types << service_types[4] # Serv_type Cons. Rural.

    puts "OK!"

    puts "Inserindo cidadão 1 ..."
    citizens[:alan] = Citizen.create({
      name: "Alan Martins de Souza",
      active: true,
      cpf: "30688943799",
      rg: "123456789",
      birth_date: "1993-01-01",
      city: city_halls[0].city,
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 42,
      email: "alan@newcastle.c3sl.ufpr.br"
    })
    accounts[:alan] = Account.create({
      uid: citizens[:alan].cpf,
      password: "123456",
      password_confirmation: "123456"
    })
    citizens[:alan].account = accounts[:alan] 
    citizens[:alan].save!
    accounts[:alan].save!

    puts "Inserindo cidadão 2 ..."
    citizens[:bruno] = Citizen.create({
      name: "Bruno Dias",
      active: true,
      cpf: "05306107010",
      rg: "123456789",
      birth_date: "1996-01-01",
      city: city_halls[0].city,
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      email: "bruno@newcastle.c3sl.ufpr.br"
    })
    accounts[:bruno] = Account.create({
      uid: citizens[:bruno].cpf,
      password: "123456",
      password_confirmation: "123456"
    })
    citizens[:bruno].account = accounts[:bruno] 
    citizens[:bruno].save!
    accounts[:bruno].save!

    puts "Inserindo cidadão 3 ..."
    citizens[:cynthia] = Citizen.create({
      name: "Cynthia Almeida Oliveira",
      active: true,
      cpf: "26646762295",
      rg: "123456789",
      birth_date: "1996-02-01",
      city: city_halls[0].city,
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      email: "cynthia@newcastle.c3sl.ufpr.br"
    })
    accounts[:cynthia] = Account.create({
      uid: citizens[:cynthia].cpf,
      password: "123456",
      password_confirmation: "123456"
    })
    citizens[:cynthia].account = accounts[:cynthia] 
    citizens[:cynthia].save!
    accounts[:cynthia].save!

    puts "Inserindo cidadão 4 ..."
    citizens[:pedro] = Citizen.create({
      name: "Pedro Monteiro Garcia",
      active: true,
      cpf: "99003488770",
      rg: "123456789",
      birth_date: "1996-01-01",
      city: city_halls[1].city,
      phone1: "(41)3333-2222",
      cep: "83065-180",
      address_number: 23,
      email: "pedro@newcastle.c3sl.ufpr.br"
    })
    accounts[:pedro] = Account.create({
      uid: citizens[:pedro].cpf,
      password: "123456",
      password_confirmation: "123456"
    })
    citizens[:pedro].account = accounts[:pedro]
    citizens[:pedro].save!
    accounts[:pedro].save!

    puts "Inserindo cidadão 5 ..."
    citizens[:fabricio] = Citizen.create({
      name: "Fabricio Tissei",
      active: true,
      cpf: "52068808765",
      rg: "123456789",
      birth_date: "1994-06-02",
      city: city_halls[1].city,
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 45,
      email: "fabricio@newcastle.c3sl.ufpr.br"
    })
    accounts[:fabricio] = Account.create({
      uid: citizens[:fabricio].cpf,
      password: "123456",
      password_confirmation: "123456"
    })
    citizens[:fabricio].account = accounts[:fabricio]
    citizens[:fabricio].save!
    accounts[:fabricio].save!

    puts "Inserindo cidadão 6 ..."
    citizens[:mateus] = Citizen.create({
      name: "Mateus Risso",
      active: true,
      cpf: "83853416845",
      rg: "123456789",
      birth_date: "1996-02-01",
      city: city_halls[0].city,
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      email: "mateus@newcastle.c3sl.ufpr.br"
    })
    accounts[:mateus] = Account.create({
      uid: citizens[:mateus].cpf,
      password: "123456",
      password_confirmation: "123456"
    })
    citizens[:mateus].account = accounts[:mateus]
    citizens[:mateus].save!
    accounts[:mateus].save!

    puts "Inserindo cidadão 7 ..."
    citizens[:joao] = Citizen.create({
      name: "João Ravedutti ",
      active: true,
      cpf: "96525184410",
      rg: "123456789",
      birth_date: "1996-02-01",
      city: city_halls[0].city,
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      email: "mateus@newcastle.c3sl.ufpr.br"
    })
    accounts[:joao] = Account.create({
      uid: citizens[:joao].cpf,
      password: "123456",
      password_confirmation: "123456"
    })
    citizens[:joao].account = accounts[:joao]
    citizens[:joao].save!
    accounts[:joao].save!

    professional_keys = [:fabricio,:pedro,:cynthia,:bruno,:alan]
    accounts.each_with_index do |(k, v), i| # Create professionals with citzens
      if professional_keys.include?(k)
        professionals[k] = Professional.create({
          registration: "1561/"+(i*27).to_s,
          occupation: occupations[i%occupations.count],
          account: v,
          active: true
        })
      end
    end

    # professionals[:joao].update_attribute(:active, false) # Deactivate a prof

    puts "Inserindo cidadão 8 ..."
    citizens[:paulo] = Citizen.create({
      name: "Paulo Brandão",
      active: true,
      cpf: "60333178076",
      rg: "123456789",
      birth_date: "1996-02-01",
      city: city_halls[0].city,
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      email: "paulo@newcastle.c3sl.ufpr.br"
    })
    accounts[:paulo] = Account.create({
      uid: citizens[:paulo].cpf,
      password: "123456",
      password_confirmation: "123456"
    })
    citizens[:paulo].account = accounts[:paulo]
    citizens[:paulo].save!
    accounts[:paulo].save!

    puts "Inserindo cidadão 9 ..."
    citizens[:henrique] = Citizen.create({
      name: "Henrique Ravedutti",
      active: true,
      cpf: "34518832108",
      rg: "123456789",
      birth_date: "1995-06-02",
      city: city_halls[1].city,
      phone1: "(41)3333-2222",
      cep: "83065-180",
      address_number: 23,
      email: "henrique@newcastle.c3sl.ufpr.br"
    })
    accounts[:henrique] = Account.create({
      uid: citizens[:henrique].cpf,
      password: "123456",
      password_confirmation: "123456"
    })
    citizens[:henrique].account = accounts[:henrique]
    citizens[:henrique].save!
    accounts[:henrique].save!

    puts "Inserindo Dependente A..."
    citizens[:dependentea] = Citizen.create({
      responsible_id: 6,
      name: "Dependente A",
      active: true,
      cpf: "48452995504",
      rg: "123456789",
      birth_date: "2001-09-09",
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      city: city_halls[0].city
    })
    Dependant.create({
      citizen_id: citizens[:dependentea].id
    })

    puts "Inserindo Dependente B..."
    citizens[:dependenteb] = Citizen.create({
      responsible_id: 6,
      name: "Dependente B",
      active: true,
      cpf: "08842966363",
      rg: "123456789",
      birth_date: "2004-01-09",
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      city: city_halls[0].city
    })
    Dependant.create({
      citizen_id: citizens[:dependenteb].id
    })

    puts "Inserindo Dependente C..."
    citizens[:dependentec] = Citizen.create({
      responsible_id: 1,
      name: "Dependente C",
      active: true,
      cpf: "47448234595",
      rg: "123456789",
      birth_date: "2004-01-09",
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      city: city_halls[0].city
    })
    Dependant.create({
      citizen_id: citizens[:dependentec].id
    })

    puts "Inserindo Dependente D..."
    citizens[:dependented] = Citizen.create({
      responsible_id: 1,
      name: "Dependente D",
      active: true,
      cpf: "35896328524",
      rg: "123456789",
      birth_date: "2014-01-09",
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      city: city_halls[1].city
    })
    Dependant.create({
      citizen_id: citizens[:dependented].id
    })

    puts "Inserindo Dependente E..."
    citizens[:dependentee] = Citizen.create({
      responsible_id: 2,
      name: "Dependente E",
      active: true,
      cpf: "58651883137",
      rg: "123456789",
      birth_date: "2011-01-09",
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      city: city_halls[1].city
    })
    Dependant.create({
      citizen_id: citizens[:dependentee].id
    })

    puts "Inserindo Dependente F..."
    citizens[:dependentef] = Citizen.create({
      responsible_id: 2,
      name: "Dependente F",
      active: true,
      cpf: "54014114058",
      rg: "123456789",
      birth_date: "2008-08-08",
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      city: city_halls[0].city
    })
    Dependant.create({
      citizen_id: citizens[:dependentef].id
    })

    puts "Inserindo Dependente G..."
    citizens[:dependenteg] = Citizen.create({
      responsible_id: 8,
      name: "Dependente G",
      active: true,
      cpf: "31656862468",
      rg: "123456789",
      birth_date: "2009-01-06",
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      city: city_halls[0].city
    })
    Dependant.create({
      citizen_id: citizens[:dependenteg].id
    })

    puts "Inserindo Dependente H..."
    citizens[:dependenteh] = Citizen.create({
      responsible_id: 7,
      name: "Dependente H",
      active: true,
      cpf: "15348827827",
      rg: "123456789",
      birth_date: "2009-01-01",
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      city: city_halls[0].city
    })
    Dependant.create({
      citizen_id: citizens[:dependenteh].id
    })

    puts "Inserindo Dependente I..."
    citizens[:dependentei] = Citizen.create({
      responsible_id: 9,
      name: "Dependente I",
      active: true,
      cpf: "88606115045",
      rg: "123456789",
      birth_date: "2008-02-09",
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      city: city_halls[1].city
    })
    Dependant.create({
      citizen_id: citizens[:dependentei].id
    })

    puts "Inserindo Dependente J..."
    citizens[:dependentej] = Citizen.create({
      responsible_id: 3,
      name: "Dependente J",
      active: true,
      cpf: "52911669088",
      rg: "123456789",
      birth_date: "2015-08-10",
      phone1: "(41)3333-2222",
      cep: "80530-908",
      address_number: 23,
      city: city_halls[1].city
    })
    Dependant.create({
      citizen_id: citizens[:dependentej].id
    })

    printf "Criando relações de permissão..."
    ProfessionalsServicePlace.create({ # Prof Fabricio as adm_c3sl service_place.first
      service_place: service_places.first,
      role: "adm_c3sl",
      active: true,
      professional: professionals[:fabricio]
    })

    ProfessionalsServicePlace.create({ # Prof Alan as adm_pref in Curitiba adm
      service_place: service_places[0],
      role: "adm_prefeitura",
      active: true,
      professional: professionals[:alan]
    })

    ProfessionalsServicePlace.create({ # Prof Fabricio as adm_pref in Sao J. adm
      service_place: service_places[1],
      role: "adm_prefeitura",
      active: true,
      professional: professionals[:fabricio]
    })

    ProfessionalsServicePlace.create({ # Prof Bruno as adm_local in Curitiba sms
      service_place: service_places[2],
      role: "adm_local",
      active: true,
      professional: professionals[:bruno]
    })

    ProfessionalsServicePlace.create({ # Prof Cynthia as atendente_local in Curitiba sms
      service_place: service_places[2],
      role: "atendente_local",
      active: true,
      professional: professionals[:cynthia]
    })

    ProfessionalsServicePlace.create({ # Prof Alan as resp_atend in Curitiba sms
      service_place: service_places[2],
      role: "responsavel_atendimento",
      active: true,
      professional: professionals[:alan]
    })

    ProfessionalsServicePlace.create({ # Prof Cynthia as adm_local in Sao J. Clinic. Odont
      service_place: service_places[3],
      role: "adm_local",
      active: true,
      professional: professionals[:cynthia]
    })

    ProfessionalsServicePlace.create({ # Prof Fabricio as atendente_local in Sao J. Clinic. Odont
      service_place: service_places[3],
      role: "atendente_local",
      active: true,
      professional: professionals[:fabricio]
    })

    ProfessionalsServicePlace.create({ # Prof Bruno as resp_atend in Sao J. Odont
      service_place: service_places[3],
      role: "responsavel_atendimento",
      active: true,
      professional: professionals[:bruno]
    })

    ProfessionalsServicePlace.create({ # Prof Pedro as adm_local in Curitiba Apoio
      service_place: service_places[4],
      role: "adm_local",
      active: true,
      professional: professionals[:pedro]
    })

    ProfessionalsServicePlace.create({ # Prof Pedro as responsavel_atendimento in Sao J. Clinic. Odont
      service_place: service_places[3],
      role: "responsavel_atendimento",
      active: true,
      professional: professionals[:pedro]
    })
    puts "OK!"

    puts "Inserindo escala 1 e seus agendamentos"
    
    shifts[0] = Shift.create({ # Create shift 1
      execution_start_time: DateTime.now.beginning_of_day + 1.day + 12.hours,
      execution_end_time: DateTime.now.beginning_of_day + 1.day + 20.hours,
      service_amount: 8,
      service_place: service_places[2], # SMS - Curitiba
      service_type: service_types[0],   # Consulta ambulatorial
      professional_responsible_id: professionals[:bruno].id,
      professional_performer_id: professionals[:alan].id
    })

    #situations = [Situation.disponivel]

    #shifts[0].service_amount.times do |i|
    #  schedules[i] = Schedule.create({
    #    shift_id: shifts[0].id,
    #    situation_id: situations[i % situations.count].id,
    #    service_place_id: shifts[0].service_place.id,
    #    service_start_time: (DateTime.now.beginning_of_hour)-(((5-i)/2).hours),
    #    service_end_time: (DateTime.now.beginning_of_hour)-(((4-i)/2).hours),
    #    account_id: accounts[:paulo].id
    #  });
    #end

    puts "Inserindo escala 2 e seus agendamentos"
    shifts[1] = Shift.create({ # Create shift 1
      execution_start_time: DateTime.now.beginning_of_day + 1.day + 24.hours,
      execution_end_time: DateTime.now.beginning_of_day + 1.day + 30.hours,
      service_amount: 8,
      service_place: service_places[2], # SMS - Curitiba
      service_type: service_types[0],   # Consulta ambulatorial
      professional_responsible_id: professionals[:bruno].id,
      professional_performer_id: professionals[:alan].id
    })

    #situations = [Situation.disponivel]
    
    #shifts[1].service_amount.times do |i|
    #  schedules[i] = Schedule.create({
    #    shift_id: shifts[1].id,
    #    situation_id: situations[i%situations.count].id,
    #    service_place_id: shifts[1].service_place.id,
    #    service_start_time: (DateTime.now.beginning_of_hour)-(((5-i)/2).hours),
    #    service_end_time: (DateTime.now.beginning_of_hour)-(((4-i)/2).hours),
    #    account_id: accounts[:mateus].id
    #  });
    #end


    puts "Inserindo escala 3 e seus agendamentos"
    shifts[2] = Shift.create({ # Create shift 1
      execution_start_time: DateTime.now.beginning_of_day + 1.day + 72.hours,
      execution_end_time: DateTime.now.beginning_of_day + 1.day + 80.hours,
      service_amount: 4,
      service_place: service_places[2], # SMS - Curitiba
      service_type: service_types[2],   # Clareamento
      professional_responsible_id: professionals[:alan].id,
      professional_performer_id: professionals[:pedro].id
    })

    #situations = [Situation.disponivel]

    #shifts[2].service_amount.times do |i|
    #  schedules[i] = Schedule.create({
    #    shift_id: shifts[2].id,
    #    situation_id: situations[i%1].id,
    #    service_place_id: shifts[2].service_place.id,
    #    service_start_time: DateTime.now.beginning_of_hour+(1+i).hours,
    #    service_end_time: DateTime.now.beginning_of_hour+(2+i).hours,
    #  });
    #end

    puts "Inserindo escala 4 e seus agendamentos"
    shifts[3] = Shift.create({ # Create shift 1
      execution_start_time: DateTime.now.beginning_of_day + 1.day + 120.hours,
      execution_end_time: DateTime.now.beginning_of_day + 1.day + 128.hours,
      service_amount: 4,
      service_place: service_places[2], # SMS - Curitiba
      service_type: service_types[2],   # Clareamento
      professional_responsible_id: professionals[:alan].id,
      professional_performer_id: professionals[:pedro].id
    })

    #situations = [Situation.disponivel]

    #shifts[3].service_amount.times do |i|
    #  schedules[i] = Schedule.create({
    #    shift_id: shifts[3].id,
    #    situation_id: situations[i%1].id,
    #    service_place_id: shifts[3].service_place.id,
    #    service_start_time: DateTime.now.beginning_of_hour+(1+i).hours+3.days,
    #    service_end_time: DateTime.now.beginning_of_hour+(2+i).hours+3.days,
    #  });
    #end

     #generate_schedules_for(shifts[0])
  end
end
