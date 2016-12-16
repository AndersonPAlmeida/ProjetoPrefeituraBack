require "test_helper"

class ShiftTest < ActiveSupport::TestCase
  describe Shift do
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
                             cep: "1234567",
                             email: "test@example.com",
                             name: "Test Example",
                             phone1: "(12)1212-1212",
                             rg: "1234567",
                             city_id: @joinville.id)

      @account = Account.new(uid: @citizen.cpf,
                             password: "123mudar",
                             password_confirmation: "123mudar")

      @city_hall = CityHall.new(name: "Prefeitura de Joinville",
                                cep: "81530110",
                                neighborhood: "Aasdsd",
                                address_street: "asdasd",
                                address_number: "100",
                                city_id: @joinville.id,
                                phone1: "12121212",
                                active: true,
                                block_text: "hello")

      @occupation = Occupation.new(description: "Cargo",
                                   name: "Teste",
                                   active: true)

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
                                        address_street: "Test Avenue",
                                        name: "Example SP",
                                        neighborhood:"Neighborhood Example")

      @service_place.city_hall = @city_hall
      @service_place.save!
      @service_type.save!

      @shift = Shift.new(execution_start_time: DateTime.now,
                         execution_end_time: DateTime.now+3,
                         professional_performer_id: @professional.id,
                         service_amount: 3)
    end

    describe "Missing service place" do
      it "should return an error" do
        @shift.service_type = @service_type
        assert_not @shift.save
        assert_not_empty @shift.errors.messages[:service_place]
      end
    end

    describe "Missing service type" do
      it "should return an error" do
        @shift.service_place = @service_place
        assert_not @shift.save
        assert_not_empty @shift.errors.messages[:service_type]
      end
    end

    describe "Successful creation" do
      it "should create a shift" do
        @number_of_shifts = Shift.count
        @shift.service_place = @service_place
        @shift.service_type = @service_type
        @shift.save!
        assert_equal @number_of_shifts + 1, Shift.count
      end
    end
  end
end
