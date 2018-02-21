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
        cep: "81530110", 
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
          cep: "89218230",
          email: "teste@teste.com",
          phone: "12121212",
          sent: true,
        }, permission: "citizen"}, headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end
    end
  end
end
