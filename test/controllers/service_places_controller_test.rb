require 'test_helper'

class Api::V1::ServicePlacesControllerTest < ActionDispatch::IntegrationTest

  describe "Token access" do
    before do

      @parana = State.new(abbreviation: "PR",
                          ibge_code: "41",
                          name: "Paraná")
      @parana.save!

      @curitiba = City.new(ibge_code: "4106902",
                           name: "Curitiba",
                           state_id: @parana.id)
      @curitiba.save!

      @citizen= Citizen.new(cpf: "10845922904",  
                             birth_date: "Apr 18 1997",  
                             cep: "1234567",  
                             email: "test@example.com", 
                             name: "Test Example",  
                             phone1: "(12)1212-1212", 
                             city_id: @curitiba.id,
                             rg: "1234567") 

      @account = Account.new(uid: @citizen.cpf, 
                             password: "123mudar", 
                             password_confirmation: "123mudar") 

      @city_hall = CityHall.new(name: "Prefeitura de Curitiba",
                                cep: "81530110",
                                neighborhood: "random",
                                address_street: "unknown",
                                address_number: "99",
                                city_id: @curitiba.id,
                                phone1: "321312",
                                active: true,
                                block_text: "hi")

      @account.save! 
      @citizen.account_id = @account.id 
      @citizen.save! 

      @city_hall.save!
      @occupation = Occupation.new(description: "Teste",
                                   name: "Tester",
                                   active: true,
                                   city_hall_id: @city_hall.id)
      @occupation.save!
      @professional = Professional.new(active: true, 
                                       registration: "123",
                                       occupation_id: @occupation.id) 
      @professional.account_id = @account.id 
      @professional.save!

      @service_place = ServicePlace.new(active: true, 
					address_number: "123",
					address_street: "Test Avenue",
					name: "Example SP",
					neighborhood:"Neighborhood Example")
      @service_place.city_hall = @city_hall
      @service_place.save!
 
      @role = ProfessionalsServicePlace.new(active:true, role: "adm_c3sl", 
				   professional_id: @professional.id,
				   service_place_id: @service_place.id)
      @role.save!

      @auth_headers = @account.create_new_auth_token 
      @token     = @auth_headers['access-token'] 
      @client_id = @auth_headers['client'] 
      @expiry    = @auth_headers['expiry'] 
    end

    describe "Succesful request to show service place" do
      before do
        get '/v1/service_places/' + @service_place.id.to_s, params: {},
						  headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should be successful" do
        assert_equal @body["id"], @controller.current_account.professional.service_places.first.id
      end
    end

    describe "Successful request to delete service place" do

    end

    describe "Successful request to update service place" do

    end
  end
end
