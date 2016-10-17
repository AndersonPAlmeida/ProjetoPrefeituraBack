require 'test_helper'

class Api::V1::Accounts::SessionsControllerTest < ActionDispatch::IntegrationTest
  describe Api::V1::Accounts::SessionsController do
    describe "Token access" do
      before do
        @santa_catarina = State.new(
          abbreviation: "SC", 
          ibge_code: "42", 
          name: "Santa Catarina"
        )
        @santa_catarina.save! 
 
        @joinville = City.new(
          ibge_code: "4209102", 
          name: "Joinville", 
          state_id: @santa_catarina.id
        )
        @joinville.save! 

        post '/v1/auth', params: {
          birth_date: "Apr 18 1997",
          cep: "81530-110",
          cpf: "10845922904",
          email: "test@example.com", 
          name: "Test Example",
          phone1: "121212-1212", 
          rg: "1234567",
          city_id: @joinville.id,
          password: "123mudar",
          password_confirmation: "123mudar"
        } 

        @citizen = Citizen.where(cpf: "10845922904").first
      end

      describe "Successful sign in" do
        before do
          post '/v1/auth/sign_in', params: {cpf: "10845922904",
                                            password: "123mudar"}, 
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
          assert_equal @controller.current_account.citizen.id, 
                       Account.where(uid: @body["data"]["uid"]).first.citizen.id
        end

        it "should correspond to the citizen in the database" do
          assert_equal Citizen.find(@citizen.id).cpf, @body["data"]["uid"]
        end
      end

      describe "Unsuccessful sign in" do
        before do
          post '/v1/auth/sign_in', params: {cpf: "11111111111",
                                            password: "123mudar"}, 
                                   headers: @auth_headers

          @body = JSON.parse(response.body)
          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']
        end

        it "should be unsuccessful" do
          assert_equal 401, response.status
        end

        it "should return an error message" do
          assert_not_empty @body['errors']
        end
      end
    end
  end
end
