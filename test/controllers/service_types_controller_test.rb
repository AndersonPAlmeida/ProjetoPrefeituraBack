require 'test_helper'

class ServiceTypesControllerTest < ActionDispatch::IntegrationTest
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
        active: true,
        birth_date: "Apr 18 1997",
        cep: "81530110",
        email: "test@example.com",
        name: "Test Example",
        phone1: "(12)1212-1212",
        address_street: "Street from Curitiba",
        address_number: "4121",
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

      @city_hall = CityHall.new(
        name: "Prefeitura de Curitiba",
        cep: "81530110",
        neighborhood: "Aasdsd",
        address_street: "asdasd",
        address_number: "100",
        city_id: @curitiba.id,
        phone1: "12121212",
        active: true,
        block_text: "hello"
      )
      @city_hall.save!

      @sector = Sector.new(
        active: true,
        name: "Setor 1",
        absence_max: 1,
        blocking_days: 2,
        cancel_limit: 3,
        description: "number one",
        schedules_by_sector: 3
      )
      @sector.city_hall = @city_hall
      @sector.save!

      @auth_headers = @account.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end
  end
end
