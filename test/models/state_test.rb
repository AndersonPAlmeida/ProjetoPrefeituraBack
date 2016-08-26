require "test_helper"

class StateTest < ActiveSupport::TestCase
  describe State do
    describe "missing name" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41")
      end

      it "should return an error" do
        @parana.save
        assert_not_empty @parana.errors.messages[:name]
      end

      it "should not save" do
        assert_not @parana.save
      end
    end

    describe "missing abbreviation" do
      before do
        @parana = State.new(ibge_code: "41",
                           name: "Parana")
      end

      it "should return an error" do
        @parana.save
        assert_not_empty @parana.errors.messages[:abbreviation]
      end

      it "should not save" do
        assert_not @parana.save
      end
    end

    describe "missing ibge code" do
      before do
        @parana = State.new(abbreviation: "PR",
                            name: "Paraná")
      end

      it "should return an error" do
        @parana.save
        assert_not_empty @parana.errors.messages[:ibge_code]
      end

      it "should not save" do
        assert_not @parana.save
      end
    end

    describe "Success" do
      before do
        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")
      end

      it "should save" do
        assert @parana.save
      end
    end
  end
end
