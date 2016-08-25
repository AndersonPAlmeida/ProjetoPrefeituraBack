require 'test_helper'

class Api::V1::ServicePlacesControllerTest < ActionDispatch::IntegrationTest

  describe "Token access" do
    before do
      @citizen= Citizen.new(cpf: "10845922904",  
                             birth_date: "Apr 18 1997",  
                             cep: "1234567",  
                             email: "test@example.com", 
                             name: "Test Example",  
                             phone1: "(12)1212-1212", 
                             rg: "1234567") 
      @account = Account.new(uid: @citizen.cpf, 
                             password: "123mudar", 
                             password_confirmation: "123mudar") 
      @professional = Professional.new(active: true, 
                                       registration: "123") 
      @service_place = ServicePlace.new(active: true, 
					address_number: "123",
					address_street: "Test Avenue",
					name: "Example SP",
					neighborhood:"Neighborhood Example")

      @account.save! 
      @citizen.account_id = @account.id 
      @citizen.save! 
      @professional.account_id = @account.id 
      @professional.save! 
 
      @auth_headers = @account.create_new_auth_token 
 
      @token     = @auth_headers['access-token'] 
      @client_id = @auth_headers['client'] 
      @expiry    = @auth_headers['expiry'] 
    end

    describe "Succesful request to show service place" do
      before do
        get '/v1/service_places/' + @service_place.id.to_s, params: {},
						  headers: @auth_headers
        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end
    end

    it "should be successful" do
      assert_equal @body["id"], @controller.current_account.professional.service_place.first
    end

    describe "Successful request to delete service place" do

    end

    describe "Successful request to update service place" do

    end

  end
end
