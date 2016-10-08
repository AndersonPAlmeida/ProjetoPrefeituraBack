require "test_helper"

class ProfessionalTest < ActiveSupport::TestCase
  describe Professional do
    describe "Sucessful professional test" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
        @parana.save!

        @curitiba = City.new(ibge_code: "4106902",
                             name: "Curitiba",
                             state_id: @parana.id)
        @curitiba.save!

        @citizen = Citizen.new(cpf: "10845922904",
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
 
        @curitiba_city_hall = CityHall.new(name: "Prefeitura de Curitiba",
                                            cep: "1234567",
                                            neighborhood: "Test neighborhood",
                                            address_street: "Test street",
                                            address_number: "123",
                                            city_id: @curitiba.id,
                                            phone1: "1414141414",
                                            active: true,
                                            block_text: "Test block text");

        @curitiba_city_hall.save!

        @occupation = Occupation.new(description: "Teste",
                                     name: "Tester",
                                     active: true,
                                     city_hall_id: @curitiba_city_hall.id)

        @occupation.save!

      	@account.save!
        @citizen.active = true
        @citizen.account_id = @account.id
      	@citizen.save!
        @professional = Professional.new(active: true,
                                         registration: "123",
                                         occupation_id: @occupation.id)
        @professional.account_id = @account.id
      end

      it "should work fine" do
    	  assert @professional.save!
      end
    end
 end
end
