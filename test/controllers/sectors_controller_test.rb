require 'test_helper'

class SectorsControllerTest < ActionDispatch::IntegrationTest
  describe "Token access" do
    before do
      @citizen = Citizen.new(cpf: "10845922904", 
                             birth_date: "Apr 18 1997", 
                             cep: "1234567", 
                             email: "test@example.com",
                             name: "Test Example", 
                             phone1: "(12)1212-1212",
                             rg: "1234567")
      @account = Account.new(uid: @citizen.cpf,
                             password: "123mudar",
                             password_confirmation: "123mudar")

      @city_hall = CityHall.new(name: "Prefeitura de Curitiba",
				cep: "81530110",
				neighborhood: "Aasdsd",
				address_street: "asdasd",
				address_number: "100",
				city_id: 4001,
				phone1: "12121212",
				active: true,
				block_text: "hello") 

      @city_hall.save!
      @citizen.active = true
      @account.save!
      @citizen.account_id = @account.id
      @citizen.save!

      @auth_headers = @account.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end

    describe "Successful request to create sector" do
      before do
        @number_of_sectors = Sector.count
        post '/v1/sectors', params: { sector: { 
		active: true, 
		city_hall_id: @city_hall.id,
		name: "Setor 1", 
		absence_max: 1, 
		blocking_days: 2, 
		cancel_limit: 3, 
		description: "the number one", 
		schedules_by_sector: 3 
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

      it "should correspond to the created sector" do
        assert_equal "Setor 1", @body["name"]
      end

      it "should correspond to the information in the database" do
        assert_equal "the number one", Sector.where(city_hall_id: @city_hall.id).first.description
      end

      it "should create a sector" do
        assert_equal @number_of_sectors + 1, Sector.count
      end

      describe "Successful request to show all sectors" do
        before do 
          get '/v1/sectors', params: {}, 
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
          assert_equal Sector.count, @body.size
        end
      end

      describe "Successful request to show city hall" do
        before do 
          @sector = Sector.where(city_hall_id: @city_hall.id).first

          get '/v1/sectors/' + @sector.id.to_s, params: {}, 
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

        it "should display the requested sector" do
          assert_equal "Setor 1", @body["name"]
        end

        it "should correspond to the information in the database" do
          assert_equal Sector.where(city_hall_id: @city_hall.id).first.name, 
                       @body["name"]
        end
      end

      describe "Unsuccessful resquest to update sector with conflicting city_hall_id" do
        before do
          @sector = Sector.where(city_hall_id: @city_hall.id).first

          put '/v1/sectors/' + @sector.id.to_s, 
                                params: {sector: {city_hall_id: "1"}},
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
          assert_not_empty @body['errors']
        end
      end
    end

    describe "Unsuccessful request to show sector that doesn't exists" do
      before do 
        get '/v1/sectors/222', params: {}, 
                                  headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should not be successful" do
        assert_equal 400, response.status
      end

      it "should return an error message" do
        assert_not_empty @body['errors']
      end
    end

    describe "Successful request to update sector" do
      before do
        @sector = Sector.where(city_hall_id: 111).first

        put '/v1/sectors/' + @sector.id.to_s,
                                params: {sector: {absence_max: "10"}}, 
                                headers: @auth_headers

        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']

      end

      it "should be successful" do
        assert_equal 200, response.status
      end

      test "absence max should have been changed" do
        @sector = Sector.where(city_hall_id: 111).first
        assert_equal 10, @sector.absence_max
      end
    end

    describe "Unsuccessful resquest to update sector that doesn't exists" do
      before do
        put '/v1/sectors/222', params: {sector: {absence_max: "10"}}, 
                                  headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should not be successful" do
        assert_equal 400, response.status
      end

      it "should return an error message" do
        assert_not_empty @body['errors']
      end
    end

    describe "Unsuccessful request to update sector without required field" do
      before do
        @sector = Sector.where(city_hall_id: 111).first

        put '/v1/sectors/' + @sector.id.to_s, 
                              params: {sector: {city_hall_id: nil}},
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
        assert_not_empty @body['errors']
      end
    end
 
    describe "Successful request to delete sector" do
      before do
        @number_of_sectors = Sector.all_active.count
        @sector = Sector.where(city_hall_id: 111).first

        delete '/v1/sectors/' + @sector.id.to_s, 
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
        assert_not Sector.where(id: @sector.id).first.active
      end

      test "number of sectors should be decreased" do
        assert_equal @number_of_sectors, Sector.all_active.count + 1
      end
    end

    describe "Unsuccessful request to delete sector that doesn't exists" do

      before do 
        @number_of_sectors = Sector.all_active.count

        delete '/v1/sectors/222', params: {}, 
                                     headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should not be successful" do
        assert_equal 400, response.status
      end

      it "should return an error message" do
        assert_not_empty @body['errors']
      end

      test "number of city halls should not be decreased" do
        assert_equal @number_of_sectors, Sector.all_active.count
      end
    end
 end
end
