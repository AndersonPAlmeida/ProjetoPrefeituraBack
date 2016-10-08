require 'test_helper'

class ServiceTypesControllerTest < ActionDispatch::IntegrationTest
  describe "Token access" do
    before do
      @parana = State.new(abbreviation: "PR",
                          ibge_code: "41",
                          name: "Paraná")
      @parana.save!

      @curitiba = City.new(ibge_code: "4106902",
                           name: "Curitiba",
                           state_id: @parana.id)
      @curitiba.save!

      @citizen = Citizen.new(cpf: "10845922904", 
                             birth_date: "Apr 18 1997", 
                             cep: "1234567", 
                             email: "test@example.com",
                             name: "Test Example", 
                             phone1: "(12)1212-1212",
                             city_id: @curitiba.id,
                             rg: "1234567")

      @account = Account.new(uid: @citizen.cpf,
                             password: "123mudar",
                             password_confirmation: "123mudar")

      @city_hall = CityHall.new(name: "Prefeitura de Curitiba",
				                        cep: "81530110",
				                        neighborhood: "Aasdsd",
				                        address_street: "asdasd",
				                        address_number: "100",
				                        city_id: @curitiba.id,
				                        phone1: "12121212",
				                        active: true,
				                        block_text: "hello") 

      @sector = Sector.new(active: true, 
	                         name: "Setor 1", 
		                       absence_max: 1, 
		                       blocking_days: 2, 
		                       cancel_limit: 3, 
		                       description: "number one", 
		                       schedules_by_sector: 3)

      @city_hall.save!

      @sector.city_hall = @city_hall
      @sector.save!

      @account.save!

      @citizen.active = true
      @citizen.account_id = @account.id
      @citizen.save!

      @auth_headers = @account.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end

    describe "Successful request to create service type" do
      before do
        @number_of_service_types = ServiceType.count

	post '/v1/service_types', params: {service_type: {
                active: true,
                sector_id: @sector.id,
                description: "type one"
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

      it "should correspond to the created service type" do
        assert_equal "type one", @body["description"]
      end

      it "should correspond to the information in the database" do
        assert_equal "type one", ServiceType.where(sector_id: @sector.id).first.description
      end

      it "should create a service type" do
        assert_equal @number_of_service_types + 1, ServiceType.count
      end

      describe "Successful request to show all service types" do
        before do 
          get '/v1/service_types', params: {}, 
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

        it "should return every service type" do
          assert_equal ServiceType.count, @body.size
        end
      end

      describe "Successful request to show service type" do
        before do 
          @service_type = ServiceType.where(sector_id: @sector.id).first

          get '/v1/service_types/' + @service_type.id.to_s, params: {}, 
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

        it "should display the requested service type" do
          assert_equal "type one", @body["description"]
        end

        it "should correspond to the information in the database" do
          assert_equal ServiceType.where(sector_id: @sector.id).first.description, @body["description"]
        end
      end

      describe "Unsuccessful resquest to update service type with conflicting sector_id" do
        before do
          @service_type = ServiceType.where(sector_id: @sector.id).first

          put '/v1/service_types/' + @service_type.id.to_s, 
                                params: {service_type: {sector_id: "222"}},
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

      describe "Successful request to update sector" do
        before do
          @service_type = ServiceType.where(sector_id: @sector.id).first

          put '/v1/service_types/' + @service_type.id.to_s,
                                  params: {service_type: {description: "type one v2"}}, 
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
          @service_type = ServiceType.where(sector_id: @sector.id).first
          assert_equal "type one v2", @service_type.description
        end
      end

      describe "Unsuccessful request to update service_type without required field" do
        before do
          @service_type = ServiceType.where(sector_id: @sector.id).first
          put '/v1/service_types/' + @service_type.id.to_s, 
                                params: {service_type: {sector_id: nil}},
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

      describe "Successful request to delete service type" do
        before do
          @number_of_service_types = ServiceType.all_active.count
          @service_type = ServiceType.where(sector_id: @sector.id).first

          delete '/v1/service_types/' + @service_type.id.to_s, 
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
          assert_not ServiceType.where(id: @service_type.id).first.active
        end

        test "number of sectors should be decreased" do
          assert_equal @number_of_service_types, ServiceType.all_active.count + 1
        end
      end
    end
  end
end
