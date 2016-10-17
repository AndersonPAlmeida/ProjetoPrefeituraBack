require 'test_helper'

class CityHallsControllerTest < ActionDispatch::IntegrationTest
  describe "Token access" do
    before do
      @parana = State.new(
        abbreviation: "PR",
        ibge_code: "41",
        name: "Paraná"
      )
      @parana.save!

      @santa_catarina = State.new(
        abbreviation: "SC",
        ibge_code: "42",
        name: "Santa Catarina"
      )
      @santa_catarina.save!

      @curitiba = City.new(
        ibge_code: "4106902",
        name: "Curitiba",
        state_id: @parana.id
      )
      @curitiba.save!

      @joinville = City.new(
        ibge_code: "4209102",
        name: "Joinville",
        state_id: @santa_catarina.id
      )
      @joinville.save!

      @joinville_city_hall = CityHall.new(
        name: "Prefeitura de Joinville",
        cep: "1234567",
        neighborhood: "Test neighborhood",
        address_street: "Test street",
        address_number: "123",
        city_id: @joinville.id,
        phone1: "1414141414",
        active: true,
        block_text: "Test block text"
      )
      @joinville_city_hall.save!

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
      @citizen.active = true

      @account = Account.new(
        uid: @citizen.cpf,
        password: "123mudar",
        password_confirmation: "123mudar"
      )

      @account.save!
      @citizen.account_id = @account.id
      @citizen.save!

      @auth_headers = @account.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end

    describe "Successful request to create city hall" do
      before do
        @number_of_city_halls = CityHall.count

        post '/v1/city_halls', params: {city_hall: {
          name: "Prefeitura de Curitiba",
          cep: "81530110",
          neighborhood: "Aasdsd",
          address_street: "asdasd",
          address_number: "100",
          city_id: @curitiba.id,
          phone1: "12121212",
          active: true,
          block_text: "hello" 
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

      it "should correspond to the created city hall" do
        assert_equal "81530110", @body["cep"]
      end

      it "should correspond to the information in the database" do
        assert_equal "100", CityHall.where(city_id: @curitiba.id).first.address_number
      end

      it "should create a city hall" do
        assert_equal @number_of_city_halls + 1, CityHall.count
      end

      describe "Successful request to show all city halls" do
        before do 
          get '/v1/city_halls', params: {}, 
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

        it "should return every city hall" do
          assert_equal CityHall.count, @body.size
        end
      end

      describe "Successful request to show city hall" do
        before do 
          @city_hall = CityHall.where(city_id: @curitiba.id).first

          get '/v1/city_halls/' + @city_hall.id.to_s, params: {}, 
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

        it "should display the requested city hall" do
          assert_equal "Prefeitura de Curitiba", @body["name"]
        end

        it "should correspond to the information in the database" do
          assert_equal CityHall.where(city_id: @curitiba.id).first.neighborhood, 
                       @body["neighborhood"]
        end
      end

      describe "Unsuccessful resquest to update city hall with conflicting city_id" do
        before do
          @city_hall = CityHall.where(city_id: @curitiba.id).first

          put '/v1/city_halls/' + @city_hall.id.to_s, 
                                params: {city_hall: {city_id: @joinville.id}},
                                headers: @auth_headers

          @body = JSON.parse(response.body)
          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']
        end

        it "should not be successful" do
          assert_equal 422, response.status
        end

        it "should return an error message" do
          assert_not_empty @body['city_id']
        end
      end
    end

    describe "Unsuccessful request to show city hall that doesn't exists" do
      before do 
        get '/v1/city_halls/222', params: {}, 
                                  headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should not be successful" do
        assert_equal 404, response.status
      end

      it "should return an error message" do
        assert_not_empty @body['errors']
      end
    end

    describe "Unsuccessful request to create city hall with missing cep" do
      before do
        @number_of_city_halls = CityHall.count

        post '/v1/city_halls', params: {city_hall: {
          name: "Prefeitura de Curitiba",
          neighborhood: "Aasdsd",
          address_street: "asdasd",
          address_number: "100",
          city_id: @curitiba.id,
          phone1: "12121212",
          active: true,
          block_text: "hello" 
        }}, headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should be unsuccessful" do
        assert_equal 422, response.status
      end

      it "should not create any city hall" do
        assert_equal @number_of_city_halls, CityHall.count
      end
    end

    describe "Unsuccessful request to create city hall with conflicting fields" do
      before do
        @number_of_city_halls = CityHall.count

        post '/v1/city_halls', params: {city_hall: {
          name: "Prefeitura de Curitiba",
          cep: "81530110",
          neighborhood: "Aasdsd",
          address_street: "asdasd",
          address_number: "100",
          city_id: @joinville.id,
          phone1: "12121212",
          active: true,
          block_text: "hello" 
        }}, headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should be unsuccessful" do
        assert_equal 422, response.status
      end

      it "should not create any city hall" do
        assert_equal @number_of_city_halls, CityHall.count
      end
    end

    describe "Successful request to delete city hall" do
      before do
        @number_of_city_halls = CityHall.all_active.count
        @city_hall = CityHall.where(city_id: @joinville.id).first

        delete '/v1/city_halls/' + @city_hall.id.to_s, 
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
        assert_not CityHall.where(id: @city_hall.id).first.active
      end

      test "number of city halls should be decreased" do
        assert_equal @number_of_city_halls, CityHall.all_active.count + 1
      end
    end

    describe "Unsuccessful request to delete city hall that doesn't exists" do
      before do 
        @number_of_city_halls = CityHall.all_active.count

        delete '/v1/city_halls/222', params: {}, 
                                     headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should not be successful" do
        assert_equal 404, response.status
      end

      it "should return an error message" do
        assert_not_empty @body['errors']
      end

      test "number of city halls should not be decreased" do
        assert_equal @number_of_city_halls, CityHall.all_active.count
      end
    end

    describe "Successful request to update city hall" do
      before do
        @city_hall = CityHall.where(city_id: @joinville.id).first

        put '/v1/city_halls/' + @city_hall.id.to_s,
                                params: {city_hall: {cep: "7654321"}}, 
                                headers: @auth_headers

        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should be successful" do
        assert_equal 200, response.status
      end

      test "cep should have been changed" do
        @city_hall = CityHall.where(city_id: @joinville.id).first
        assert_equal "7654321", @city_hall.cep
      end
    end

    describe "Unsuccessful resquest to update city hall that doesn't exists" do
      before do
        put '/v1/city_halls/222', params: {city_hall: {cep: "7654321"}}, 
                                  headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should not be successful" do
        assert_equal 404, response.status
      end

      it "should return an error message" do
        assert_not_empty @body['errors']
      end
    end

    describe "Unsuccessful request to update city hall without required field" do
      before do
        @city_hall = CityHall.where(city_id: @joinville.id).first

        put '/v1/city_halls/' + @city_hall.id.to_s, 
                              params: {city_hall: {name: nil}},
                              headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should not be successful" do
        assert_equal 422, response.status
      end

      it "should return an error message" do
        assert_not_empty @body['name']
      end
    end
  end
end
