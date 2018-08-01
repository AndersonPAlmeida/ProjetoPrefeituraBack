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

class Api::V1::ShiftsControllerTest < ActionDispatch::IntegrationTest
  describe "Token access" do
    before do
      @santa_catarina = State.new(
        abbreviation: "SC",
        ibge_code: "42",
        name: "Santa Catarina"
      )
      @santa_catarina.save!

      @joinville = City.new(
        ibge_code: "4209102",
        name: "Joinville",
        state_id: @santa_catarina.id
      )
      @joinville.save!

      @citizen = Citizen.new(
        cpf: "10845922904",
        active: true,
        birth_date: "Apr 18 1997",
        cep: "89218230",
        email: "test@example.com",
        name: "Test Example",
        phone1: "(12)1212-1212",
        rg: "1234567",
        address_street: "Street from Joinville",
        address_number: "444",
        city_id: @joinville.id
      )

      @account = Account.new(
        uid: @citizen.cpf,
        password: "123mudar",
        password_confirmation: "123mudar"
      )
      @account.save!
      @citizen.account_id = @account.id
      @citizen.save!

      @city_hall = CityHall.new(
        name: "Prefeitura de Joinville",
        cep: "89218230",
        neighborhood: "Aasdsd",
        address_street: "asdasd",
        address_number: "100",
        city_id: @joinville.id,
        phone1: "12121212",
        active: true,
        block_text: "hello"
      )
      @city_hall.save!

      @occupation = Occupation.new(
        description: "Cargo",
        name: "Teste",
        active: true
      )
      @occupation.city_hall_id = @city_hall.id
      @occupation.save!

      @sector = Sector.new(
        active: true,
        name: "Setor 1",
        absence_max: 1,
        blocking_days: 2,
        cancel_limit: 3,
        description: "number one",
        schedules_by_sector: 3
      )
      @sector.city_hall = @city_hall
      @sector.save!

      @professional = Professional.new(
        active: true,
        registration: "123"
      )
      @professional.account_id = @account.id
      @professional.occupation_id = @occupation.id
      @professional.save!

      @service_type = ServiceType.new(
        active: true,
        description: "type one"
      )
      @service_type.sector = @sector

      @service_place = ServicePlace.new(
        active: true,
        address_number: "123",
        name: "Example SP",
        cep: "89221005",
        city_hall_id: @city_hall.id
      )
      @service_place.city_hall = @city_hall
      @service_place.save!
      @service_type.save!


      @situation = Situation.new(
        description: "Waiting"
      )
      @situation.save!

      @disponivel = Situation.new(
        description: "Disponível"
      )
      @disponivel.save!

      @shift = Shift.new(
        execution_start_time: DateTime.now,
        execution_end_time: DateTime.now+3,
        service_amount: 3,
        service_type_id: @service_type.id,
        service_place_id: @service_place.id
      )
      @shift.save!

      @auth_headers = @account.create_new_auth_token
      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']
    end
  end
end
