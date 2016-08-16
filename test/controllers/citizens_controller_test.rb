require 'test_helper'

class Api::V1::CitizensControllerTest < ActionDispatch::IntegrationTest
  describe "Token access" do
    before do
      @citizen = Citizen.new(cpf: "123.456.789-04", 
                             birth_date: "18/04/1997", 
                             cep: "1234567", 
                             email: "test@example.com",
                             name: "Test Example", 
                             phone1: "(12)1212-1212",
                             rg: "1234567")
      @account = Account.new(uid: @citizen.cpf,
                             password: "123mudar",
                             password_confirmation: "123mudar")
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
        get '/v1/citizens/' + @citizen.id.to_s, params: {}, headers: @auth_headers

        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end 

      it "should be successful" do
        assert_equal 200, response.status
      end

      it "should correspond to the current account" do
        assert_equal @citizen.id, @controller.current_account.citizen.id
      end
    end

    describe "Successful request to delete citizen" do
      before do
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
        assert_nil Citizen.where(id: @citizen.id).first
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

      test "cpf should have been changed" do
        assert_equal "7654321", @citizen.cep
      end
    end
  end
end
