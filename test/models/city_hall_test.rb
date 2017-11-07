require "test_helper"

class CityTest < ActiveSupport::TestCase
  describe City do
    describe "missing name" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
        @parana.save!
        @curitiba = City.new(name: "Curitiba",
                             ibge_code: "4106902",
                             state_id: @parana.id)
        @curitiba.save!

        @city_hall = CityHall.new(cep: "81530110",
                                  neighborhood: "Test neighborhood",
                                  address_street: "Test street",
                                  address_number: "123",
                                  city_id: @curitiba.id,
                                  phone1: "1414141414",
                                  active: true,
                                  block_text: "Test block text");
      end

      it "should return an error" do
        @city_hall.save
        assert_not_empty @city_hall.errors.messages[:name]
      end

      it "should not save" do
        assert_not @city_hall.save
      end
    end

    describe "missing cep" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
        @parana.save!
        @curitiba = City.new(name: "Curitiba",
                             ibge_code: "4106902",
                             state_id: @parana.id)
        @curitiba.save!

        @city_hall = CityHall.new(name: "Prefeitura de Curitiba",
                                  neighborhood: "Test neighborhood",
                                  address_street: "Test street",
                                  address_number: "123",
                                  city_id: @curitiba.id,
                                  phone1: "1414141414",
                                  active: true,
                                  block_text: "Test block text");
      end

      it "should return an error" do
        @city_hall.save
        assert_not_empty @city_hall.errors.messages[:cep]
      end

      it "should not save" do
        assert_not @city_hall.save
      end
    end

    describe "missing neighborhood" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
        @parana.save!
        @curitiba = City.new(name: "Curitiba",
                             ibge_code: "4106902",
                             state_id: @parana.id)
        @curitiba.save!

        @city_hall = CityHall.new(name: "Prefeitura de Curitiba",
                                  cep: "81530110",
                                  address_street: "Test street",
                                  address_number: "123",
                                  city_id: @curitiba.id,
                                  phone1: "1414141414",
                                  active: true,
                                  block_text: "Test block text");
      end

      it "should return an error" do
        @city_hall.save
        assert_not_empty @city_hall.errors.messages[:neighborhood]
      end

      it "should not save" do
        assert_not @city_hall.save
      end
    end

    describe "missing address street" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
        @parana.save!
        @curitiba = City.new(name: "Curitiba",
                             ibge_code: "4106902",
                             state_id: @parana.id)
        @curitiba.save!

        @city_hall = CityHall.new(name: "Prefeitura de Curitiba",
                                  cep: "81530110",
                                  neighborhood: "Test neighborhood",
                                  address_number: "123",
                                  city_id: @curitiba.id,
                                  phone1: "1414141414",
                                  active: true,
                                  block_text: "Test block text");
      end

      it "should return an error" do
        @city_hall.save
        assert_not_empty @city_hall.errors.messages[:address_street]
      end

      it "should not save" do
        assert_not @city_hall.save
      end
    end

    describe "missing address number" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
        @parana.save!
        @curitiba = City.new(name: "Curitiba",
                             ibge_code: "4106902",
                             state_id: @parana.id)
        @curitiba.save!

        @city_hall = CityHall.new(name: "Prefeitura de Curitiba",
                                  cep: "81530110",
                                  neighborhood: "Test neighborhood",
                                  address_street: "Test street",
                                  city_id: @curitiba.id,
                                  phone1: "1414141414",
                                  active: true,
                                  block_text: "Test block text");
      end

      it "should return an error" do
        @city_hall.save
        assert_not_empty @city_hall.errors.messages[:address_number]
      end

      it "should not save" do
        assert_not @city_hall.save
      end
    end

    describe "missing city id" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
        @parana.save!
        @curitiba = City.new(name: "Curitiba",
                             ibge_code: "4106902",
                             state_id: @parana.id)
        @curitiba.save!

        @city_hall = CityHall.new(name: "Prefeitura de Curitiba",
                                  cep: "81530110",
                                  neighborhood: "Test neighborhood",
                                  address_street: "Test street",
                                  address_number: "123",
                                  phone1: "1414141414",
                                  active: true,
                                  block_text: "Test block text");
      end

      it "should return an error" do
        @city_hall.save
        assert_not_empty @city_hall.errors.messages[:city_id]
      end

      it "should not save" do
        assert_not @city_hall.save
      end
    end

    describe "missing phone1" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
        @parana.save!
        @curitiba = City.new(name: "Curitiba",
                             ibge_code: "4106902",
                             state_id: @parana.id)
        @curitiba.save!

        @city_hall = CityHall.new(name: "Prefeitura de Curitiba",
                                  cep: "81530110",
                                  neighborhood: "Test neighborhood",
                                  address_street: "Test street",
                                  address_number: "123",
                                  city_id: @curitiba.id,
                                  active: true,
                                  block_text: "Test block text");
      end

      it "should return an error" do
        @city_hall.save
        assert_not_empty @city_hall.errors.messages[:phone1]
      end

      it "should not save" do
        assert_not @city_hall.save
      end
    end

    describe "successful" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
        @parana.save!
        @curitiba = City.new(name: "Curitiba",
                             ibge_code: "4106902",
                             state_id: @parana.id)
        @curitiba.save!

        @city_hall = CityHall.new(name: "Prefeitura de Curitiba",
                                  cep: "81530110",
                                  neighborhood: "Test neighborhood",
                                  address_street: "Test street",
                                  address_number: "123",
                                  city_id: @curitiba.id,
                                  phone1: "1414141414",
                                  active: true,
                                  block_text: "Test block text");
      end

      it "should save" do
        assert @city_hall.save
      end
    end
  end
end
