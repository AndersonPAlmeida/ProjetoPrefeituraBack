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
                                         cep: "1234567",
                                         neighborhood: "Test neighborhood",
                                         address_street: "Test street",
                                         address_number: "123",
                                         city_id: @curitiba.id,
                                         phone1: "1414141414",
                                         active: true,
                                         block_text: "Test block text")
      @curitiba_city_hall.save!
    end

    describe "missing name " do
      before do
        @occupation = Occupation.new(description: "Teste",
                                     active: true,
                                     city_hall_id: @curitiba_city_hall.id)
      end

      it "should return an error" do
        @occupation.save
        assert_not_empty @occupation.errors.messages[:name]
      end

      it "should not save" do
        assert_not @occupation.save
      end
    end

    describe "missing description id" do
      before do
        @occupation = Occupation.new(name: "Tester",
                                     active: true,
                                     city_hall_id: @curitiba_city_hall.id)
      end

      it "should return an error" do
        @occupation.save
        assert_not_empty @occupation.errors.messages[:description]
      end

      it "should not save" do
        assert_not @occupation.save
      end
    end

    describe "missing active" do
      before do
        @occupation = Occupation.new(name: "Tester",
                                     description: "Teste",
                                     city_hall_id: @curitiba_city_hall.id)
      end

      it "should return an error" do
        @occupation.save
        assert_not_empty @occupation.errors.messages[:active]
      end

      it "should not save" do
        assert_not @occupation.save
      end
    end

    describe "missing city hall id" do
      before do
        @occupation = Occupation.new(name: "Tester",
                                     description: "Teste",
                                     active: true)
      end

      it "should return an error" do
        @occupation.save
        assert_not_empty @occupation.errors.messages[:city_hall_id]
      end

      it "should not save" do
        assert_not @occupation.save
      end
    end

    describe "Success" do
      before do
        @occupation = Occupation.new(name: "Tester",
                                     description: "Teste",
                                     active: true,
                                     city_hall_id: @curitiba_city_hall.id)
      end

      it "should save" do
        assert @occupation.save
      end
    end
  end
end
