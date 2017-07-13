require 'test_helper'

class Api::V1::ShiftsControllerTest < ActionDispatch::IntegrationTest
  describe "Token access" do
    before do
      @santa_catarina = State.new(
        abbreviation: "SC",
        ibge_code: "42",
        name: "Santa Catarina"
      )
      @santa_catarina.save!

      @joinville = City.new(
        ibge_code: "4209102",
        name: "Joinville",
        state_id: @santa_catarina.id
      )
      @joinville.save!

      @citizen = Citizen.new(
        cpf: "10845922904",
        active: true,
        birth_date: "Apr 18 1997",
        cep: "1234567",
        email: "test@example.com",
        name: "Test Example",
        phone1: "(12)1212-1212",
        rg: "1234567",
        city_id: @joinville.id
      )

      @account = Account.new(
        uid: @citizen.cpf,
        password: "123mudar",
        password_confirmation: "123mudar"
      )
      @account.save!
      @citizen.account_id = @account.id
      @citizen.save!

      @city_hall = CityHall.new(
        name: "Prefeitura de Joinville",
        cep: "81530110",
        neighborhood: "Aasdsd",
        address_street: "asdasd",
        address_number: "100",
        city_id: @joinville.id,
        phone1: "12121212",
        active: true,
        block_text: "hello"
      )
      @city_hall.save!

      @occupation = Occupation.new(
        description: "Cargo",
        name: "Teste",
        active: true
      )
      @occupation.city_hall_id = @city_hall.id
      @occupation.save!

      @sector = Sector.new(
        active: true,
        name: "Setor 1",
        absence_max: 1,
        blocking_days: 2,
        cancel_limit: 3,
        description: "number one",
        schedules_by_sector: 3
      )
      @sector.city_hall = @city_hall
      @sector.save!

      @professional = Professional.new(
        active: true,
        registration: "123"
      )
      @professional.account_id = @account.id
      @professional.occupation_id = @occupation.id
      @professional.save!

      @service_type = ServiceType.new(
        active: true,
        description: "type one"
      )
      @service_type.sector = @sector

      @service_place = ServicePlace.new(
        active: true,
        address_number: "123",
        address_street: "Test Avenue",
        name: "Example SP",
        neighborhood:"Neighborhood Example"
      )
      @service_place.city_hall = @city_hall
      @service_place.save!
      @service_type.save!

      

      @situation = Situation.new(
        description: "Waiting"
      )
      @situation.save!

      @disponivel = Situation.new(
        description: "Disponível"
      )
      @disponivel.save!

      @shift = Shift.new(
        execution_start_time: DateTime.now,
        execution_end_time: DateTime.now+3,
        service_amount: 3,
        service_type_id: @service_type.id,
        service_place_id: @service_place.id
      )
      @shift.save!

      @auth_headers = @account.create_new_auth_token 
      @token     = @auth_headers['access-token'] 
      @client_id = @auth_headers['client'] 
      @expiry    = @auth_headers['expiry'] 
    end

    describe "Succesful request to create shift" do
      before do
        @number_of_shifts = Shift.count
        @number_of_schedules = Schedule.count

        post '/v1/shifts', params: { shift: {
          execution_start_time: DateTime.now,
          execution_end_time: DateTime.now+3,
          service_amount: 3,
          service_type_id: @service_type.id,
          service_place_id: @service_place.id
        }}, headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should be successful" do
        assert_equal 201, response.status
      end

      it "should correspond to the created shift" do
        assert_equal 3, @body["service_amount"]
      end

      it "should increase de number of schedules in service_amount times" do
        assert_equal @number_of_schedules + @body["service_amount"], Schedule.count
      end

      it "should create service_amount schedules" do
        assert_equal @body["service_amount"], Schedule.where(shift_id: @body["id"]).count
      end

      it "should correspond to the information in the database" do
        assert_equal 3, Shift.where(service_type_id: @service_type.id).first.service_amount
      end

      it "should create a shift" do
        assert_equal @number_of_shifts + 1, Shift.count
      end

      describe "Succesful request to show shift" do
        before do

          @shift = Shift.where(service_place_id: @service_place.id).first

          get '/v1/shifts/' + @shift.id.to_s, params: {},
            headers: @auth_headers
          @body = JSON.parse(response.body)
          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']
        end

        it "should be successful" do
          assert_equal @body["id"], @shift.id
        end
      end
      describe "Succesful request to show all shifts" do
        before do

          get '/v1/shifts/', params: {},
            headers: @auth_headers
          @body = JSON.parse(response.body)
          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']
        end

        it "should be successful" do
          assert_equal 200, response.status
        end

        it "should return every shift" do
          assert_equal Shift.count, @body.size
        end
      end

      describe "Successful request to update shift" do
        before do
          @shift = Shift.where(service_place_id: @service_place.id).first

          put '/v1/shifts/' + @shift.id.to_s,
            params: {shift: {service_amount: 13}},
            headers: @auth_headers

          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']

        end

        it "should be successful" do
          assert_equal 200, response.status
        end

        test "service amount should have been changed" do
          @shift = Shift.where(service_place_id: @service_place.id).first
          assert_equal 13, @shift.service_amount
        end
      end

      describe "Successful request to delete shift" do
        before do
          @number_of_shifts = Shift.count
          @shift = Shift.where(service_place_id: @service_place.id).first

          delete '/v1/shifts/' + @shift.id.to_s,
            params: {},
            headers: @auth_headers

          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']
        end

        it "should be successful" do
          assert_equal 204, response.status
        end

        it "should have been deleted" do
          assert_equal 0, Shift.where(id: @shift.id).first.service_amount
        end

        test "number of shifts should be decreased" do
          assert_equal @number_of_shifts, Shift.where("service_amount > 0").count + 1
        end
      end
    end
  end
end

