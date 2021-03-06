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

class ShiftTest < ActiveSupport::TestCase
  describe Shift do
    before do
      @santa_catarina = State.new(abbreviation: "SC",
                                  ibge_code: "42",
                                  name: "Santa Catarina")
      @santa_catarina.save!

      @joinville = City.new(ibge_code: "4209102",
                            name: "Joinville",
                            state_id: @santa_catarina.id)
      @joinville.save!

      @citizen = Citizen.new(cpf: "10845922904",
                             active: true,
                             birth_date: "Apr 18 1997",
                             cep: "89218230",
                             email: "test@example.com",
                             name: "Test Example",
                             phone1: "(12)1212-1212",
                             rg: "1234567",
                             address_street: "Some street",
                             address_number: "1234",
                             city_id: @joinville.id)

      @account = Account.new(uid: @citizen.cpf,
                             password: "123mudar",
                             password_confirmation: "123mudar")

      @city_hall = CityHall.new(name: "Prefeitura de Joinville",
                                cep: "89218230",
                                neighborhood: "Aasdsd",
                                address_street: "asdasd",
                                address_number: "100",
                                phone1: "12121212",
                                active: true,
                                block_text: "hello")


      @occupation = Occupation.new(description: "Cargo",
                                   name: "Teste",
                                   active: true)

      @professional = Professional.new(active: true,
                                       registration: "123")

      @account.save!
      @citizen.account_id = @account.id
      @citizen.save!

      @city_hall.save!

      @occupation.city_hall_id = @city_hall.id
      @occupation.save!

    end

    describe "Missing relations" do
      it "should return an error" do
        assert_not @professional.save
        assert_not_empty @professional.errors.messages[:occupation]
        assert_not_empty @professional.errors.messages[:account]
      end
    end

    describe "Successful creation" do
      it "should create a professional" do
        @number_of_professionals = Professional.count
        @professional.account_id = @account.id
        @professional.occupation_id = @occupation.id
        @professional.save!
        assert_equal @number_of_professionals + 1, Professional.count
      end
    end
  end
end
