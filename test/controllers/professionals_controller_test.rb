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

require 'test_helper'

class Api::V1::ProfessionalsControllerTest < ActionDispatch::IntegrationTest
  describe "Token access" do
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

      @citizen= Citizen.new(
        active: true,
        cpf: "10845922904",
        birth_date: "18/04/1997",
        cep: "81530110", 
        email: "test@example.com",
        name: "Test Example",
        phone1: "(12)1212-1212",
        rg: "1234567",
        address_street: "Street from Curitiba",
        address_number: "4121",
        city_id: @curitiba.id
      )

      @account = Account.new(
        uid: @citizen.cpf,
        password: "123mudar",
        password_confirmation: "123mudar"
      )
      @account.save!
      @citizen.account_id = @account.id
      @citizen.save!

      @curitiba_city_hall = CityHall.new(
        name: "Prefeitura de Curitiba",
        cep: "81530110",
        neighborhood: "Test neighborhood",
        address_street: "Test street",
        address_number: "123",
        phone1: "1414141414",
        active: true,
        block_text: "Test block text"
      )
      @curitiba_city_hall.save!

      @occupation = Occupation.new(
        description: "Teste",
        name: "Tester",
        active: true,
        city_hall_id: @curitiba_city_hall.id
      )
      @occupation.save!

      @auth_headers = @account.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end

    describe "Unsuccessful request to create professional" do
      before do
        @number_of_professionals = Professional.count

        post '/v1/professionals', params: {professional: {
          active: true,
          registration: "123",
          occupation_id: @occupation.id,
          account_id: @account.id
        }, permission: "citizen"}, headers: @auth_headers

        @body = JSON.parse(response.body)
        @resp_token = response.headers['access-token']
        @resp_client_id = response.headers['client']
        @resp_expiry = response.headers['expiry']
        @resp_uid = response.headers['uid']
      end

      it "should not be permitted" do
        assert_equal 422, response.status
      end

      it "should not create a professional" do
        assert_equal @number_of_professionals, Professional.count
      end

      describe "Unsuccessful request to show all professionals" do
        before do
          get '/v1/professionals', params: {permission: "citizen"},
            headers: @auth_headers

          @body = JSON.parse(response.body)
          @resp_token = response.headers['access-token']
          @resp_client_id = response.headers['client']
          @resp_expiry = response.headers['expiry']
          @resp_uid = response.headers['uid']
        end

        it "should not be permitted" do
          assert_equal 403, response.status
        end
      end
    end
  end
end
