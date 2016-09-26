require "test_helper"

class Api::V1::CepControllerTest < ActionDispatch::IntegrationTest
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
      @citizen.active = true
      @account.save!
      @citizen.account_id = @account.id
      @citizen.save!

      @auth_headers = @account.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end

    describe "Successful cep validation" do
      before do 
        post '/v1/validate_cep', params: {cep: {number: "81530110"}}, 
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

      it "should correspond to actual address" do
        assert_equal "Jardim das Américas", @body["neighborhood"]
      end
    end

    describe "Unsuccessful cep validation" do
      before do 
        post '/v1/validate_cep', params: {cep: {number: "81530111"}},
                                 headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end 

      it "should be successful" do
        assert_equal 400, response.status
      end

      it "should return an error" do
        assert_equal ["Invalid CEP."], @body["errors"]
      end
    end
  end
end
