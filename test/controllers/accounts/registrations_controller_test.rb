require 'test_helper'

class Api::V1::Accounts::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  describe Api::V1::Accounts::RegistrationsController do
    describe "Successful registration" do
      before do
        @number_of_accounts = Account.count
        @number_of_citizens = Citizen.count

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
          city_id: @joinville.id,
          rg: "1234567",
          password: "123mudar",
          password_confirmation: "123mudar"
        } 

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      it "should be successful" do
        assert_equal 200, response.status
      end

      test "number of accounts should have been increased" do
        assert_equal Account.count, @number_of_accounts + 1
      end

      test "number of citizens should have been increased" do
        assert_equal Citizen.count, @number_of_citizens + 1
      end

      test "account should have been created" do
        assert @resource.id
      end

      test "new user data should be returned as json" do
        assert_equal @resource.uid, @data['uid']
      end
    end

    describe "Register with invalid cpf" do
      before do
        @number_of_accounts = Account.count
        @number_of_citizens = Citizen.count

        post '/v1/auth', params: {
          birth_date: "Apr 18 1997",
          cep: "81530-110",
          cpf: "12345678910",
          email: "test@example.com", 
          name: "Test Example",
          phone1: "121212-1212", 
          rg: "1234567",
          password: "123mudar",
          password_confirmation: "123mudar"
        } 

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      it "should not be successful" do
        assert_equal 422, response.status
      end

      it "should return an error message" do
        assert_not_empty @data['errors']
      end

      it "should return an error status" do
        assert_equal 'error', @data['status']
      end

      it "should not increase number of citizens" do
        assert_equal @number_of_citizens, Citizen.count
      end

      it "should not increase number of accounts" do
        assert_equal @number_of_accounts, Account.count
      end
    end
  
    describe "Empty body" do
      before do
        @number_of_citizens = Citizen.count
        @number_of_accounts = Account.count

        post '/v1/auth', params: {}

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      it "should not be successful" do
        assert_equal 422, response.status
      end

      it "should return an error message" do
        assert_not_empty @data['errors']
      end

      it "should return the error status" do
        assert_equal 'error', @data['status']
      end

      test "user should not have been saved" do
        assert @resource.nil?
      end

      it "should not increase number of citizens" do
        assert_equal @number_of_citizens, Citizen.count
      end

      it "should not increase number of accounts" do
        assert_equal @number_of_accounts, Account.count
      end
    end

    describe "Unsuccessful registration" do
      before do
        @number_of_citizens = Citizen.count
        @number_of_accounts = Account.count

        post '/v1/auth', params: {
          birth_date: "Jan 1 1980",
          cep: "1122334",
          cpf: "52998224725",
          email: "john@john.com", 
          name: "John",
          phone1: "12341234", 
          rg: "1234123",
          password: "123mudar",
          password_confirmation: "123mudar"
        }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      it "should not be successful" do
        assert_equal 422, response.status
      end

      it "should return an error message" do
        assert_not_empty @data['errors']
      end

      it "should return an error status" do
        assert_equal 'error', @data['status']
      end

      it "should not increase number of citizens" do
        assert_equal @number_of_citizens, Citizen.count
      end

      it "should not increase number of accounts" do
        assert_equal @number_of_accounts, Account.count
      end
    end

    describe "Missing necessary field" do
      before do
        @number_of_citizens = Citizen.count
        @number_of_accounts = Account.count

        post '/v1/auth', params: {
          cep: "1122334",
          cpf: "10845922904",
          email: "john@john.com", 
          name: "John",
          phone1: "12341234", 
          rg: "1234123",
          password: "123mudar",
          password_confirmation: "123mudar"
        }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      it "should not be successful" do
        assert_equal 422, response.status
      end

      it "should return an error message" do
        assert_not_empty @data['errors']
      end

      it "should return the error status" do
        assert_equal 'error', @data['status']
      end

      it "should not increase number of citizens" do
        assert_equal @number_of_citizens, Citizen.count
      end

      it "should not increase number of accounts" do
        assert_equal @number_of_accounts, Account.count
      end
    end

    describe "Blank cpf" do
      before do
        @number_of_citizens = Citizen.count
        @number_of_accounts = Account.count

        post '/v1/auth', params: {
          birth_date: "Jan 1 1980",
          cep: "1122334",
          email: "john@john.com", 
          name: "John",
          phone1: "12341234", 
          rg: "1234123",
          password: "123mudar",
          password_confirmation: "123mudar"
        }

        @resource = assigns(:resource)
        @data = JSON.parse(response.body)
      end

      it "should not be successful" do
        assert_equal 422, response.status
      end

      it "should return an error message" do
        assert_not_empty @data['errors']
      end

      it "should return the error status" do
        assert_equal 'error', @data['status']
      end

      it "should not increase number of citizens" do
        assert_equal @number_of_citizens, Citizen.count
      end

      it "should not increase number of accounts" do
        assert_equal @number_of_accounts, Account.count
      end
    end
  end
end
