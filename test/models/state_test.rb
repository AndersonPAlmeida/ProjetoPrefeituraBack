# This file is part of Agendador.
#
# Agendador is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Agendador is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Agendador.  If not, see <https://www.gnu.org/licenses/>.

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
