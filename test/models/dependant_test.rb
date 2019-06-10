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

class DependantTest < ActiveSupport::TestCase
  describe Dependant do
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
                             address_number: 1234,
                             city_id: @joinville.id)

      @account = Account.new(uid: @citizen.cpf,
                             password: "123mudar",
                             password_confirmation: "123mudar")

      @dependant = Dependant.new()

      @account.save!
      @citizen.account = @account
      @citizen.save!

    end

    describe "Missing citizen" do
      it "should return an error" do
        assert_not @dependant.save
        assert_not_empty @dependant.errors.messages[:citizen]
      end
    end

    describe "Successful creation" do
      it "should create a dependant" do
        @number_of_dependants = Dependant.count
        @dependant.citizen = @citizen
        @dependant.save!
        assert_equal @number_of_dependants + 1, Dependant.count
      end
    end
  end
end
