require "test_helper"

class SectorTest < ActiveSupport::TestCase
  describe Sector do
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
    end

    describe "Missing city hall" do
      it "should return an error" do
        @sector.save
        assert_not @sector.save
        assert_not_empty @sector.errors.messages[:city_hall]
      end
    end

    describe "Successful creation" do
      it "should create a sector" do
        @number_of_sectors = Sector.count
        @sector.city_hall = @city_hall
        @sector.save!
        assert_equal @number_of_sectors + 1, Sector.count
      end
    end
  end
end
