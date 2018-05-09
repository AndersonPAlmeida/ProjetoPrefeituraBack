require 'test_helper'

class Api::V1::DependantsControllerTest < ActionDispatch::IntegrationTest
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

      @responsible = Citizen.new(
        active: true,
        cpf: "10845922904",
        birth_date: "18/04/1997",
        cep: "89218230",
        email: "test@example.com",
        name: "Test Example",
        phone1: "(12)1212-1212",
        address_street: "Street from Joinville",
        address_number: "444",
        city_id: @joinville.id,
        rg: "1234567"
      )

      @account = Account.new(
        uid: @responsible.cpf,
        password: "123mudar",
        password_confirmation: "123mudar"
      )

      @account.save!
      @responsible.account_id = @account.id
      @responsible.save!

      @auth_headers = @account.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end

    describe "Successful request to create dependant" do
      before do
        @number_of_dependants = Dependant.count

        post '/v1/citizens/' + @responsible.id.to_s + '/dependants', params: {
          dependant: {
            active: true,
            cpf: "18472377628",
            birth_date: "16/03/2004",
            cep: "89218230",
            email: "test@example.com",
            name: "Test Example Dep",
            phone1: "(12)1212-1212",
            city_id: @joinville.id,
            address_number: 123456,
            rg: "1234567"
          }, permission: "citizen"
        }, headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should be successful" do
        assert_equal 201, response.status
      end

      it "should correspond to the created dependant" do
          @dependant = Dependant.where(citizens: {
            responsible_id: @responsible.id
          }).includes(:citizen).first
        assert_equal @dependant.citizen.id, @body["citizen"]["id"]
      end

      it "should create a dependant" do
        assert_equal @number_of_dependants + 1, Dependant.count
      end

      describe "Successful request to show dependant" do
        before do
          @dependant = Dependant.where(citizens: {
            responsible_id: @responsible.id
          }).includes(:citizen).first

          get '/v1/citizens/' + @responsible.id.to_s + '/dependants/' + @dependant.id.to_s,
            params: {permission: "citizen"},
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
          assert_equal Citizen.find(@body["citizen"]["id"]).responsible_id, @controller
            .current_account.citizen.id
        end

        it "should correspond to the dependant in the database" do
          assert_equal @body["citizen"]["cpf"], Dependant.find(@dependant.id).citizen.cpf
        end
      end

      describe "Successful request to delete dependant" do
        before do
          @dependant = Dependant.where(citizens: {
            responsible_id: @responsible.id
          }).includes(:citizen).first

          delete '/v1/citizens/' + @responsible.id.to_s + '/dependants/' + @dependant.id.to_s,
            params: {permission: "citizen"},
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
          assert_equal Dependant.where(id: @dependant.id).first.citizen.active, false
        end
      end

      describe "Successful request to update dependant" do
        before do
          @dependant = Dependant.where(citizens: {
            responsible_id: @responsible.id
          }).includes(:citizen).first

          put '/v1/citizens/' + @responsible.id.to_s + '/dependants/' + @dependant.id.to_s,
            params: {dependant: { phone1: "(41)13131313" }, permission: "citizen"},
            headers: @auth_headers

          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']
        end

        it "should be successful" do
          assert_equal 200, response.status
        end

        test "phone number should have been changed" do
          @dependant = Dependant.where(citizens: {
            responsible_id: @responsible.id
          }).includes(:citizen).first

          assert_equal "(41)13131313", @dependant.citizen.phone1
        end
      end
    end
  end
end
