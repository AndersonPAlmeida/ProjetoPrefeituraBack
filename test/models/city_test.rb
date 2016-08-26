require "test_helper"

class CityTest < ActiveSupport::TestCase
  describe City do
    describe "missing name" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
        @parana.save!
        @curitiba = City.new(ibge_code: "4106902",
                             state_id: @parana.id)
      end

      it "should return an error" do
        @curitiba.save
        assert_not_empty @curitiba.errors.messages[:name]
      end

      it "should not save" do
        assert_not @curitiba.save
      end
    end

    describe "missing state id" do
      before do
        @curitiba = City.new(ibge_code: "4106902",
                             name: "Curitiba")
      end

      it "should return an error" do
        @curitiba.save
        assert_not_empty @curitiba.errors.messages[:state_id]
      end

      it "should not save" do
        assert_not @curitiba.save
      end
    end

    describe "missing ibge code" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
        @parana.save!
        @curitiba = City.new(name: "Curitiba",
                             state_id: @parana.id)
      end

      it "should return an error" do
        @curitiba.save
        assert_not_empty @curitiba.errors.messages[:ibge_code]
      end

      it "should not save" do
        assert_not @curitiba.save
      end
    end

    describe "Success" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
        @parana.save!
        @curitiba = City.new(ibge_code: "4106902",
                             name: "Curitiba",
                             state_id: @parana.id)
      end

      it "should save" do
        assert @curitiba.save
      end
    end
  end
end
