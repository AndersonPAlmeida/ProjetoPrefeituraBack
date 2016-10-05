require 'test_helper'

class Api::V1::SchedulesControllerTest < ActionDispatch::IntegrationTest

  describe "Token access" do
    before do
      @citizen= Citizen.new(cpf: "10845922904",  
                             birth_date: "Apr 18 1997",  
                             cep: "1234567",  
                             email: "test@example.com", 
                             name: "Test Example",  
                             phone1: "(12)1212-1212", 
                             rg: "1234567") 

      @account = Account.new(uid: @citizen.cpf, 
                             password: "123mudar", 
                             password_confirmation: "123mudar") 

      @professional = Professional.new(active: true, 
                                       registration: "123") 

      @city_hall = CityHall.new(name: "Prefeitura de Curitiba",
				cep: "81530110",
				neighborhood: "random",
				address_street: "unknown",
				address_number: "99",
				city_id: 4001,
				phone1: "321312",
				active: true,
				block_text: "hi"
			       )


      @sector = Sector.new(active: true,
                name: "Setor 1",
                absence_max: 1,
                blocking_days: 2,
                cancel_limit: 3,
                description: "number one",
                schedules_by_sector: 3)
      

      @account.save! 
      @citizen.account_id = @account.id 
      @citizen.save! 
      @professional.account_id = @account.id 
      @professional.save!

      @city_hall.save!
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
                         service_amount: 3,
                         service_type_id: @service_type.id,
                         service_place_id: @service_place.id)

      @shift.save!

      @situation = Situation.new(description: 'Waiting')
      @situation.save!

      @auth_headers = @account.create_new_auth_token 
      @token     = @auth_headers['access-token'] 
      @client_id = @auth_headers['client'] 
      @expiry    = @auth_headers['expiry'] 
    end

    describe "Succesful request to create schedule" do
      before do

	@number_of_schedules = Schedule.count

        post '/v1/schedules/', params: { schedule: {
              shift_id: @shift.id,
              situation_id: @situation.id,
              service_place_id: @service_place.id,
              citizen_ajax_read: 1,
              professional_ajax_read: 1,
              reminder_read: 1,
              service_start_time: DateTime.now,
              service_end_time: DateTime.now+5
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

      it "should correspond to the created schedule" do
        assert_equal @service_place.id, @body["service_place"]["id"]
      end

      it "should correspond to the information in the database" do
        assert_equal @service_place.id, Schedule.where(situation_id: @situation.id).first.service_place_id
      end

      it "should create a shift" do
        assert_equal @number_of_schedules + 1, Schedule.count
      end

      describe "Succesful request to show schedule" do
        before do

          @schedule = Schedule.where(situation_id: @situation.id).first
	
          get '/v1/schedules/' + @schedule.id.to_s, params: {},
						    headers: @auth_headers
          @body = JSON.parse(response.body)
          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']
        end

        it "should be successful" do
          assert_equal @body["id"], @schedule.id
        end
      end

      describe "Succesful request to show all schedules" do
        before do

          get '/v1/schedules/', params: {},
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
          assert_equal Schedule.count, @body.size
        end
      end
    end
  end
end

