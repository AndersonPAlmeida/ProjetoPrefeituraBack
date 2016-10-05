require 'test_helper'

class Api::V1::DependantsControllerTest < ActionDispatch::IntegrationTest
  describe "Token access" do
    before do
      @citizen= Citizen.new(cpf: "10845922904", 
                             birth_date: "18/04/1997", 
                             cep: "1234567", 
                             email: "test@example.com",
                             name: "Test Example", 
                             phone1: "(12)1212-1212",
                             rg: "1234567")
      @account = Account.new(uid: @citizen.cpf,
                             password: "123mudar",
                             password_confirmation: "123mudar")
      @dependant = Dependant.new(active: true)

      @account.save!
      @citizen.account_id = @account.id
      @citizen.save!
      @dependant.citizen_id = @citizen.id
      @dependant.save!

      @auth_headers = @account.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end

    describe "Successful request to show dependant" do
      before do 
        get '/v1/dependants/' + @dependant.id.to_s, params: {}, 
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
        assert_equal @body["id"], @controller.current_account.citizen.dependant.id
      end

      it "should correspond to the dependant in the database" do
        assert_equal @body["citizen"]["cpf"], Dependant.find(@dependant.id).citizen.cpf
      end
    end

    describe "Successful request to delete dependant" do
      before do
        delete '/v1/dependants/' + @dependant.id.to_s, params: {}, 
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
        assert_equal Dependant.where(id: @dependant.id).first.active, false
      end
    end

    describe "Successful request to update dependant" do
      before do
        put '/v1/dependants/' + @dependant.id.to_s,
                                       params: {dependant: { active: false  }},                                       		      headers: @auth_headers
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should be successful" do
        assert_equal 200, response.status
      end

      test "registration number should have been changed" do
        @dependant = Citizen.where(cpf: @citizen.cpf).first.dependant
        assert_equal false, @dependant.active
      end
    end
  end
end
