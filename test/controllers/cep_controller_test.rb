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

class Api::V1::CepControllerTest < ActionDispatch::IntegrationTest
  describe "City creation" do
    before do
      @parana = State.new(
        abbreviation: "PR",
        ibge_code: "41",
        name: "Paraná"
      )
      @parana.save!

      @curitiba = City.new(
        ibge_code: "4106902",
        name: "Curitiba",
        state_id: @parana.id
      )
      @curitiba.save!

      @curitiba_city_hall = CityHall.new(
        name: "Prefeitura de Curitiba",
        cep: "81530110",
        neighborhood: "Test neighborhood",
        address_street: "Test street",
        address_number: "123",
        phone1: "1414141414",
        active: true,
        block_text: "Test block text"
      );
      @curitiba_city_hall.save!
    end

    describe "Successful cep validation" do
      before do
        post '/v1/validate_cep', params: {cep: {number: "81530110"}}

        @body = JSON.parse(response.body)
      end

      it "should be successful" do
        assert_equal 200, response.status
      end

      it "should correspond to actual address" do
        assert_equal "Jardim das Américas", @body["neighborhood"]
      end
    end

    describe "Unsuccessful cep validation that doesn't exist" do
      before do
        post '/v1/validate_cep', params: {cep: {number: "815301112"}}

        @body = JSON.parse(response.body)
      end

      it "should be successful" do
        assert_equal 422, response.status
      end

      it "should return an error" do
        assert_equal ["CEP inválido!"], @body["errors"]
      end
    end

    describe "Unsuccessful cep validation that is not registered" do
      before do
        post '/v1/validate_cep', params: {cep: {number: "89218230"}}

        @body = JSON.parse(response.body)
      end

      it "should be successful" do
        assert_equal 404, response.status
      end

      it "should return an error" do
        assert_equal ["Cidade não registrada!"], @body["errors"]
      end
    end
  end
end
