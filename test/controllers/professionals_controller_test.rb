require 'test_helper'

class Api::V1::ProfessionalsControllerTest < ActionDispatch::IntegrationTest
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
        birth_date: "18/04/1997", 
        cep: "1234567", 
        email: "test@example.com",
        name: "Test Example", 
        phone1: "(12)1212-1212",
        rg: "1234567",
        city_id: @curitiba.id
      )

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

      @occupation = Occupation.new(
        description: "Teste",
        name: "Tester",
        active: true,
        city_hall_id: @curitiba_city_hall.id
      )
      @occupation.save!

      @auth_headers = @account.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end

    describe "Successful request to create professional" do
      before do 
        @number_of_professionals = Professional.count

        post '/v1/professionals', params: {professional: {
          active: true,
          registration: "123",
          occupation_id: @occupation.id,
          account_id: @account.id
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

      it "should correspond to the created professional" do
        assert_equal "123", @body["registration"]
      end

      it "should correspond to the information in the database" do
        assert_equal @occupation.id, Professional.where(account_id: @account.id).first.occupation_id
      end

      it "should create a city hall" do
        assert_equal @number_of_professionals + 1, Professional.count
      end

      describe "Successful request to show all professionals" do
        before do 
          get '/v1/professionals', params: {}, 
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
          assert_equal Professional.count, @body.size
        end

      end

      describe "Successful request to show professional" do
        before do 
          @professional = Professional.where(account_id: @account.id).first
          get '/v1/professionals/' + @professional.id.to_s, params: {}, 
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
          assert_equal "123", @body["registration"]
        end

        it "should correspond to the information in the database" do
          assert_equal Professional.where(account_id: @account.id).first.occupation_id, 
            @body["occupation"]["id"]
        end

      end

      describe "Successful request to delete professional" do
        before do
          @professional = Professional.where(account_id: @account.id).first

          @number_of_professionals = Professional.all_active.count

          delete '/v1/professionals/' + @professional.id.to_s, params: {}, 
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
          assert_not Professional.where(id: @professional.id).first.active
        end

        test "number of active professional should be decreased" do
          assert_equal @number_of_professionals, Professional.all_active.count + 1
        end
      end

      describe "Successful request to update professional" do
        before do
          @professional = Professional.where(account_id: @account.id).first

          put '/v1/professionals/' + @professional.id.to_s,
            params: {professional: {registration: "7654/21" }}, #{professional: {registration: "7654/21"}}, 
            headers: @auth_headers

          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']
        end

        it "should be successful" do
          assert_equal 200, response.status
        end

        test "registration number should have been changed" do
          @professional = Citizen.where(cpf: @citizen.cpf).first.account.professional
          assert_equal "7654/21", @professional.registration
        end
      end
    end
  end
end
