require 'test_helper'

class SolicitationsControllerTest < ActionDispatch::IntegrationTest
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
        active: true,
        cpf: "10845922904", 
        birth_date: "Apr 18 1997", 
        cep: "1234567", 
        email: "test@example.com",
        name: "Test Example", 
        phone1: "(12)1212-1212",
        city_id: @curitiba.id,
        rg: "1234567"
      )

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

    describe "Successful request to create solicitation" do
      before do
        @number_of_solicitations = Solicitation.count

        post '/v1/solicitations', params: {solicitation: {
          city_id: @curitiba.id,
          name: "Teste",
          cpf: "10845922904",
          cep: "81530110",
          email: "teste@teste.com",
          phone: "12121212",
          sent: true,
        }}, headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should be successful" do
        assert_equal 201, response.status
      end

      it "should correspond to the created solicitations" do
        assert_equal "10845922904", @body["cpf"]
      end

      it "should correspond to the information in the database" do
        assert_equal "Teste", Solicitation.where(city_id: @curitiba.id).first.name
      end

      it "should create a solicitation" do
        assert_equal @number_of_solicitations + 1, Solicitation.count
      end

      describe "Successful request to show all soliciations" do
        before do 
          get '/v1/solicitations', params: {}, 
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

        it "should return every solicitation" do
          assert_equal Solicitation.count, @body.size
        end
      end

      describe "Successful request to show solicitation" do
        before do 
          @solicitation = Solicitation.where(city_id: @curitiba.id).first

          get '/v1/solicitations/' + @solicitation.id.to_s, params: {}, 
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

        it "should display the requested solicitation" do
          assert_equal "Teste", @body["name"]
        end

        it "should correspond to the information in the database" do
          assert_equal Solicitation.where(city_id: @curitiba.id).first.name, 
            @body["name"]
        end
      end

      describe "Successful request to delete solicitation" do
        before do
          @number_of_solicitations = Solicitation.count
          @solicitation = Solicitation.where(city_id: @curitiba.id).first

          delete '/v1/solicitations/' + @solicitation.id.to_s,
            params: {},
            headers: @auth_headers

          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']
        end

        it "should be successful" do
          assert_equal 204, response.status
        end

        test "number of solicitations decreased" do
          assert_equal @number_of_solicitations - 1, Solicitation.count
        end
      end

      describe "Successful request to update solicitation" do
        before do
          @solicitation = Solicitation.where(city_id: @curitiba.id).first

          put '/v1/solicitations/' + @solicitation.id.to_s,
            params: {solicitation: {
            name: "Teste2"
          }},
          headers: @auth_headers

          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']
        end

        it "should be successful" do
          assert_equal 200, response.status
        end

        it "should update solicitation" do
          assert_equal "Teste2", Solicitation.where(city_id: @curitiba.id).first.name
        end
      end
    end

    describe "Unsuccessful request to show solicitation that doesn't exist" do
      before do 
        get '/v1/solicitations/222', params: {}, 
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

    describe "Unsuccessful request to create solicitation with invalid cpf" do
      before do
        @number_of_solicitations = Solicitation.count

        post '/v1/solicitations', params: {solicitation: {
          city_id: @curitiba.id,
          name: "Teste",
          cpf: "12345678910",
          cep: "81530110",
          email: "teste@teste.com",
          phone: "12121212",
          sent: true,
        }}, headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should not be successful" do
        assert_equal 422, response.status
      end

      it "should not create a solicitation" do
        assert_equal @number_of_solicitations, Solicitation.count
      end

      it "should return an error" do
        assert_not_empty @body["cpf"]
      end
    end
  end
end
