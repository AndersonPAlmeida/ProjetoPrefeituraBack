require "test_helper"

class ScheduleTest < ActiveSupport::TestCase
  describe Schedule do
    before do
      @santa_catarina = State.new(abbreviation: "SC",
                                  ibge_code: "42",
                                  name: "Santa Catarina")
      @santa_catarina.save!

      @joinville = City.new(ibge_code: "4209102",
                            name: "Joinville",
                            state_id: @santa_catarina.id)
      @joinville.save!

      @citizen = Citizen.new(cpf: "10845922904",
                             active: true,
                             birth_date: "Apr 18 1997",
                             cep: "89218230",
                             email: "test@example.com",
                             name: "Test Example",
                             phone1: "(12)1212-1212",
                             rg: "1234567",
                             city_id: @joinville.id)

      @account = Account.new(uid: @citizen.cpf,
                             password: "123mudar",
                             password_confirmation: "123mudar")

      @city_hall = CityHall.new(name: "Prefeitura de Joinville",
                                cep: "89218230",
                                neighborhood: "Aasdsd",
                                address_street: "asdasd",
                                address_number: "100",
                                phone1: "12121212",
                                active: true,
                                block_text: "hello")

      @occupation = Occupation.new(description: "Cargo",
                                   name: "Teste",
                                   active: true)
      @situation = Situation.new(
        description: "Waiting"
      )
      @situation.save!

      @disponivel = Situation.new(
        description: "Disponível"
      )
      @disponivel.save!

      @sector = Sector.new(active: true,
                           name: "Setor 1",
                           absence_max: 1,
                           blocking_days: 2,
                           cancel_limit: 3,
                           description: "number one",
                           schedules_by_sector: 3)

      @professional = Professional.new(active: true,
                                       registration: "123")


      @account.save!
      @citizen.account_id = @account.id
      @citizen.save!

      @city_hall.save!

      @occupation.city_hall_id = @city_hall.id
      @occupation.save!

      @professional.account_id = @account.id
      @professional.occupation_id = @occupation.id
      @professional.save!

      @sector.city_hall = @city_hall
      @sector.save!

      @service_type = ServiceType.new(active: true,
                                      description: "type one")

      @service_type.sector = @sector

      @service_place = ServicePlace.new(active: true,
                                        address_number: "123",
                                        city_hall_id: @city_hall.id,
                                        name: "Example SP",
                                        cep: "89218230")

      @service_place.save!
      @service_type.save!

      @shift = Shift.new(execution_start_time: DateTime.now,
                         execution_end_time: DateTime.now+3,
                         professional_performer_id: @professional.id,
                         service_type_id: @service_type.id,
                         service_place_id: @service_place.id,
                         service_amount: 3)

      @shift.service_place = @service_place
      @shift.service_type = @service_type
      @shift.save!

      @schedule = Schedule.new(citizen_ajax_read: 0,
                               professional_ajax_read: 0,
                               reminder_read: 0,
                               service_start_time: DateTime.now,
                               service_end_time: DateTime.now+3)

    end

    describe "Missing relations" do
      it "should return an error" do
        assert_not @schedule.save
        assert_not_empty @schedule.errors.messages[:service_place]
        assert_not_empty @schedule.errors.messages[:shift]
        assert_not_empty @schedule.errors.messages[:situation]
      end
    end

    describe "Successful creation" do
      it "should create a schedule" do
        @number_of_schedules = Schedule.count
        @schedule.service_place = @service_place
        @schedule.shift = @shift
        @schedule.situation = @situation
        @schedule.save!
        assert_equal @number_of_schedules + 1, Schedule.count
      end
    end
  end
end
