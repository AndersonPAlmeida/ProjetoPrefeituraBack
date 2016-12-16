require 'test_helper'

class OccupationsControllerTest < ActionDispatch::IntegrationTest
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

      @citizen = Citizen.new(
        cpf: "10845922904",
        birth_date: "Apr 18 1997",
        cep: "1234567",
        email: "test@example.com",
        name: "Test Example",
        phone1: "(12)1212-1212",
        city_id: @curitiba.id,
        rg: "1234567"
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

      @curitiba_city_hall = CityHall.new(
        name: "Prefeitura de Curitiba",
        cep: "1234567",
        neighborhood: "Test neighborhood",
        address_street: "Test street",
        address_number: "123",
        city_id: @curitiba.id,
        phone1: "1414141414",
        active: true,
        block_text: "Test block text"
      )
      @curitiba_city_hall.save!

      @auth_headers = @account.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end

    describe "Successful request to create occupation" do
      before do
        @number_of_occupations = Occupation.count

        post '/v1/occupations', params: {occupation: {
          description: "Teste",
          name: "Tester",
          active: true,
          city_hall_id: @curitiba_city_hall.id
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

      it "should correspond to the created occupation" do
        assert_equal "Teste", @body["description"]
      end

      it "should create a occupation" do
        assert_equal @number_of_occupations + 1, Occupation.count
      end

      describe "Successful request to show all occupations" do
        before do
          get '/v1/occupations', params: {},
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
          assert_equal Occupation.count, @body.size
        end
      end
    end

    describe "Unsuccessful request to show occupation that doesn't exists" do
      before do
        get '/v1/occupations/222', params: {},
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

    describe "Unsuccessful request to create occupation with missing city_hall" do
      before do
        @number_of_occupations = Occupation.count

        post '/v1/occupations', params: {occupation: {
          description: "Teste",
          name: "Tester",
          active: true,
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

      it "should not create any occupation" do
        assert_equal @number_of_occupations, Occupation.count
      end
    end

    describe "Unsuccessful request to delete occupation that doesn't exists" do
      before do
        @number_of_occupations = Occupation.all_active.count

        delete '/v1/occupations/222', params: {},
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

      test "number of occupations should not be decreased" do
        assert_equal @number_of_occupations, Occupation.all_active.count
      end
    end
  end
end
