require "test_helper"

class OccupationTest < ActiveSupport::TestCase
  describe Occupation do
    before do
      @parana = State.new(abbreviation: "PR",
                          ibge_code: "41",
                          name: "Paraná")
      @parana.save!
      @curitiba = City.new(name: "Curitiba",
                           ibge_code: "4106902",
                           state_id: @parana.id)
      @curitiba.save!
      @curitiba_city_hall = CityHall.new(name: "Prefeitura de Curitiba",
                                         cep: "81530110",
                                         neighborhood: "Test neighborhood",
                                         address_street: "Test street",
                                         address_number: "123",
                                         city_id: @curitiba.id,
                                         phone1: "1414141414",
                                         active: true,
                                         block_text: "Test block text")
      @curitiba_city_hall.save!
    end
  end
end
