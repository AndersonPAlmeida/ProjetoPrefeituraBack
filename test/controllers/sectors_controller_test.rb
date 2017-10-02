require 'test_helper'

class SectorsControllerTest < ActionDispatch::IntegrationTest
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

      @citizen = Citizen.new(
        cpf: "10845922904",
        active: true,
        birth_date: "Apr 18 1997",
        cep: "1234567",
        email: "test@example.com",
        name: "Test Example",
        phone1: "(12)1212-1212",
        rg: "1234567",
        city_id: @joinville.id
      )

      @account = Account.new(
        uid: @citizen.cpf,
        password: "123mudar",
        password_confirmation: "123mudar"
      )
      @account.save!
      @citizen.account_id = @account.id
      @citizen.save!

      @city_hall = CityHall.new(
        name: "Prefeitura de Joinville",
        cep: "81530110",
        neighborhood: "Aasdsd",
        address_street: "asdasd",
        address_number: "100",
        city_id: @joinville.id,
        phone1: "12121212",
        active: true,
        block_text: "hello"
      )
      @city_hall.save!

      @auth_headers = @account.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end

    describe "Unsuccessful request to create sector" do
      before do
        @number_of_sectors = Sector.count
        post '/v1/sectors', params: { sector: {
          active: true,
          city_hall_id: @city_hall.id,
          name: "Setor 1",
          absence_max: 1,
          blocking_days: 2,
          cancel_limit: 3,
          description: "the number one",
          schedules_by_sector: 3
        }, permission: "citizen"}, headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should not be successful" do
        assert_equal 403, response.status
      end

      it "should not  create a sector" do
        assert_equal @number_of_sectors, Sector.count
      end

      describe "Unsuccessful request to show all sectors" do
        before do
          get '/v1/sectors', params: {permission: "citizen"},
            headers: @auth_headers

          @body = JSON.parse(response.body)
          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']
        end

        it "should not be successful" do
          assert_equal 403, response.status
        end

        it "should return an error message" do
          assert_not_empty @body["errors"]
        end
      end

      describe "Unsuccessful request to show sector that doesn't exists" do
        before do
          get '/v1/sectors/222', params: {permission: "citizen"},
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

      describe "Unsuccessful resquest to update sector that doesn't exists" do
        before do
          put '/v1/sectors/222', params: {sector: {absence_max: "10"}, permission: "citizen"},
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

      describe "Unsuccessful request to delete sector that doesn't exists" do

        before do
          @number_of_sectors = Sector.all_active.count

          delete '/v1/sectors/222', params: {permission: "citizen"},
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

        test "number of sectors should not be decreased" do
          assert_equal @number_of_sectors, Sector.all_active.count
        end
      end
    end
  end
end
