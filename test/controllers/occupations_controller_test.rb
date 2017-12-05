require 'test_helper'

class OccupationsControllerTest < ActionDispatch::IntegrationTest
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
        cpf: "10845922904",
        birth_date: "Apr 18 1997",
        cep: "80530336",
        email: "test@example.com",
        name: "Test Example",
        phone1: "(12)1212-1212",
        city_id: @curitiba.id,
        rg: "1234567"
      )
      @citizen.active = true

      @account = Account.new(
        uid: @citizen.cpf,
        password: "123mudar",
        password_confirmation: "123mudar"
      )
      @account.save!
      @citizen.account_id = @account.id
      @citizen.save!

      @curitiba_city_hall = CityHall.new(
        name: "Prefeitura de Curitiba",
        cep: "81530110",
        neighborhood: "Test neighborhood",
        address_street: "Test street",
        address_number: "123",
        city_id: @curitiba.id,
        phone1: "1414141414",
        active: true,
        block_text: "Test block text"
      )
      @curitiba_city_hall.save!

      @auth_headers = @account.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end
  end
end
