require 'test_helper'

class Api::V1::CitizensControllerTest < ActionDispatch::IntegrationTest
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
        rg: "1234567",
        city_id: @curitiba.id
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

    describe "Successful request to show citizen" do
      before do 
        get '/v1/citizens/' + @citizen.id.to_s, params: {}, 
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

      it "should correspond to the current account" do
        assert_equal @controller.current_account.citizen.id, @body["id"]
      end

      it "should correspond to the citizen in the database" do
        assert_equal Citizen.find(@citizen.id).cpf, @body["cpf"]
      end
    end

    describe "Unsuccessful request to show citizen that doesn't exists" do
      before do 
        get '/v1/citizens/222', params: {}, 
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

    describe "Successful request to show all citizens" do
      before do
        get '/v1/citizens', params: {}, headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should be successful" do
        assert_equal 200, response.status
      end
  
      # TODO: change to return only the citizens that SHOULD be displayed
      # (e.g. only local citizens)
      it "should return all citizens" do
        assert_equal Citizen.count, @body.size
      end
    end

    describe "Successful request to delete citizen" do
      before do
        @number_of_citizens = Citizen.all_active.count

        delete '/v1/citizens/' + @citizen.id.to_s, params: {}, 
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
        assert_not Citizen.where(id: @citizen.id).first.active
      end

      test "number of citizen should be decreased" do
        assert_equal @number_of_citizens, Citizen.all_active.count + 1
      end
    end

    describe "Unsuccessful request to delete citizen that doesn't exists" do
      before do
        @number_of_citizens = Citizen.all_active.count

        delete '/v1/citizens/222', params: {}, 
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

      test "number of citizen should not be decreased" do
        assert_equal @number_of_citizens, Citizen.all_active.count
      end
    end

    describe "Successful request to update citizen" do
      before do
        put '/v1/citizens/' + @citizen.id.to_s,
                                       params: {citizen: {cep: "7654321"}}, 
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
        @citizen = Citizen.where(cpf: @citizen.cpf).first
        assert_equal "7654321", @citizen.cep
      end
    end

    describe "Unsuccessful resquest to update citizen that doesn't exists" do
      before do
        put '/v1/citizens/222', params: {citizen: {cep: "7654321"}}, 
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

    describe "Unsuccessful resquest to update citizen with conflicting cpf" do
      before do
        put '/v1/citizens/' + @citizen.id.to_s, 
                              params: {citizen: {cpf: "11111111111"}},
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
        assert_not_empty @body['cpf']
      end
    end

    describe "Unsuccessful request to update citizen without required field" do
      before do
        put '/v1/citizens/' + @citizen.id.to_s, 
                              params: {citizen: {name: nil}},
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
