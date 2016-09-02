require 'test_helper'

class Api::V1::ProfessionalsControllerTest < ActionDispatch::IntegrationTest
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
      @professional = Professional.new(active: true,
				       registration: "123")
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

    describe "Successful request to show professional" do
      before do 
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

      it "should correspond to the current account" do
        assert_equal @body["id"], @controller.current_account.professional.id
      end

      it "should correspond to the professional in the database" do
        assert_equal @body["citizen"]["cpf"], Professional.find(@professional.id).account.citizen.cpf
      end
    end

    describe "Successful request to delete professional" do
      before do
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
