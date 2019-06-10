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
