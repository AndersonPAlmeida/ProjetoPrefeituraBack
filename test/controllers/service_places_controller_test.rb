require 'test_helper'

class Api::V1::ServicePlacesControllerTest < ActionDispatch::IntegrationTest
  describe "Token access" do
    before do
      @parana = State.new(
        abbreviation: "PR",
        ibge_code: "41",
        name: "Paraná"
      )
      @parana.save!

      @curitiba = City.new(
        ibge_code: "4106902",
        name: "Curitiba",
        state_id: @parana.id
      )
      @curitiba.save!

      @citizen= Citizen.new(
        active: true,
        cpf: "10845922904",  
        birth_date: "Apr 18 1997",  
        cep: "1234567",  
        email: "test@example.com", 
        name: "Test Example",  
        phone1: "(12)1212-1212", 
        city_id: @curitiba.id,
        rg: "1234567"
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
        name: "Prefeitura de Curitiba",
        cep: "81530110",
        neighborhood: "random",
        address_street: "unknown",
        address_number: "99",
        city_id: @curitiba.id,
        phone1: "321312",
        active: true,
        block_text: "hi"
      )
      @city_hall.save!

      @occupation = Occupation.new(
        description: "Teste",
        name: "Tester",
        active: true,
        city_hall_id: @city_hall.id
      )
      @occupation.save!

      @professional = Professional.new(
        active: true, 
        registration: "123",
        occupation_id: @occupation.id
      )
      @professional.account_id = @account.id 
      @professional.save!

      @auth_headers = @account.create_new_auth_token 
      @token     = @auth_headers['access-token'] 
      @client_id = @auth_headers['client'] 
      @expiry    = @auth_headers['expiry'] 
    end

    describe "Successful request to create service place" do
      before do
        @number_of_service_places = ServicePlace.count

        post '/v1/service_places', params: {service_place: {
                active: true,
                address_number: "123",
                address_street: "Test Avenue",
                city_hall_id: @city_hall.id,
                name: "Example SP",
                neighborhood: "Neighborhood Example"
        }}, headers: @auth_headers

        @body = JSON.parse(response.body)

        @role = ProfessionalsServicePlace.new(active: true, 
                                              role: "adm_c3sl", 
                                              professional_id: @professional.id,
                                              service_place_id: @body['id'])
        @role.save!

        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should be successful" do
        assert_equal 201, response.status
      end

      it "should correspond to the created service place" do
        assert_equal "Test Avenue", @body["address_street"]
      end

      it "should correspond to the information in the database" do
        assert_equal "Example SP", ServicePlace.where(city_hall_id: @city_hall.id).first.name
      end

      it "should create a service place" do
        assert_equal @number_of_service_places+1, ServicePlace.count
      end

      describe "Successful request to show all service places" do
        before do
          @service_place = ServicePlace.where(name: "Example SP").first

          get '/v1/service_places/', params: {},
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

        it "should return every service place" do
          assert_equal ServicePlace.count, @body.size
        end
      end


      describe "Successful request to show service place" do
        before do
          @service_place = ServicePlace.where(name: "Example SP").first

          get '/v1/service_places/' + @service_place.id.to_s, params: {},
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

        it "should display the requested service place" do
          assert_equal @body['neighborhood'], "Neighborhood Example"
        end

        it "should correspond to the information in the database" do
          assert_equal ServicePlace.where(city_hall_id: @city_hall.id).first.address_street, "Test Avenue"
        end
      end

      describe "Successful request to delete service place" do
        before do
          @service_place = ServicePlace.where(name: "Example SP").first

          put '/v1/service_places/' + @service_place.id.to_s,
                                  params: {service_place: {name: "New name"}},
                                  headers: @auth_headers

          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']

        end

        it "should be successful" do
          assert_equal 200, response.status
        end

        test "description should have been changed" do
          @service_place = ServicePlace.where(city_hall_id: @city_hall.id).first
          assert_equal "New name", @service_place.name
        end
      end

      describe "Successful request to update service place" do
        before do
          @number_of_service_places = ServicePlace.count
          @service_place = ServicePlace.where(name: "Example SP").first

          delete '/v1/service_places/' + @service_place.id.to_s,
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
          assert_not ServicePlace.where(id: @service_place.id).first.active
        end

        test "number of service places should be decreased" do
          assert_equal @number_of_service_places, ServicePlace.all_active.count + 1
        end
      end
    end
  end
end
