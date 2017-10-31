require 'test_helper'

class Api::V1::ServicePlacesControllerTest < ActionDispatch::IntegrationTest
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

      @citizen= Citizen.new(
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

      @city_hall = CityHall.new(
        name: "Prefeitura de Curitiba",
        cep: "81530110",
        neighborhood: "random",
        address_street: "unknown",
        address_number: "99",
        city_id: @curitiba.id,
        phone1: "321312",
        active: true,
        block_text: "hi"
      )
      @city_hall.save!

      @occupation = Occupation.new(
        description: "Teste",
        name: "Tester",
        active: true,
        city_hall_id: @city_hall.id
      )
      @occupation.save!

      @professional = Professional.new(
        active: true, 
        registration: "123",
        occupation_id: @occupation.id
      )
      @professional.account_id = @account.id 
      @professional.save!

      @auth_headers = @account.create_new_auth_token 
      @token     = @auth_headers['access-token'] 
      @client_id = @auth_headers['client'] 
      @expiry    = @auth_headers['expiry'] 
    end

    
  end
end
