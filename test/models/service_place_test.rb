require "test_helper"

class ServicePlaceTest < ActiveSupport::TestCase
  describe ServicePlace do
    before do
      @parana = State.new(abbreviation: "PR",
                          ibge_code: "41",
                          name: "Paraná")
      @parana.save!

      @curitiba = City.new(ibge_code: "4106902",
                           name: "Curitiba",
                           state_id: @parana.id)
      @curitiba.save!

      @city_hall = CityHall.new(name: "Prefeitura de Curitiba",
                                cep: "81530110",
                                neighborhood: "Aasdsd",
                                address_street: "asdasd",
                                address_number: "100",
                                city_id: @curitiba.id,
                                phone1: "12121212",
                                active: true,
                                block_text: "hello") 

      @service_place = ServicePlace.new(active: true, 
                                        address_number: "12", 
                                        name: "Service P", 
                                        cep: "81530110")

      @city_hall.save!
    end

    describe "Missing city hall" do
      it "should return an error" do
        @service_place.save
        assert_not @service_place.save
        assert_not_empty @service_place.errors.messages[:city_hall]
      end
    end

    describe "Successful creation" do
      it "should create a service place" do
        @number_of_service_places = ServicePlace.count
        @service_place.city_hall = @city_hall
        @service_place.save!
        assert_equal @number_of_service_places + 1, ServicePlace.count
      end
    end
  end
end
