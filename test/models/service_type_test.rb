require "test_helper"

class ServiceTypeTest < ActiveSupport::TestCase
  describe ServiceType do
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

      @sector = Sector.new(active: true, 
                           name: "Setor 1", 
                           absence_max: 1, 
                           blocking_days: 2, 
                           cancel_limit: 3, 
                           description: "number one", 
                           schedules_by_sector: 3)

      @city_hall.save!

      @sector.city_hall = @city_hall
      @sector.save!

      @service_type = ServiceType.new(active: true,
                                      description: "type_one")
    end

    describe "Missing sector" do
      it "should return an error" do
        @service_type.save
	      assert_not @service_type.save
	      assert_not_empty @service_type.errors.messages[:sector]
      end
    end

    describe "Successful creation" do
      it "should create a service type" do
        @number_of_service_types = ServiceType.count
        @service_type.sector_id = @sector.id
        @service_type.save
        assert_equal @number_of_service_types + 1, ServiceType.count
      end
    end
  end
end
