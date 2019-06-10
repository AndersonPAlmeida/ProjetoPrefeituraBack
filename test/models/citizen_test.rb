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

class CitizenTest < ActiveSupport::TestCase
  describe Citizen do
    describe "Missing cpf" do
      before do

        @parana = State.new(abbreviation: "PR",
                            ibge_code: "41",
                            name: "Paraná")

        @parana.save!

        @curitiba = City.new(ibge_code: "4106902",
                             name: "Curitiba",
                             state_id: @parana.id)
        @curitiba.save!

        @citizen = Citizen.new(birth_date: "Apr 18 1997",
                               cep: "81530110",
                               address_number: 1234,
                               email: "test@example.com",
                               name: "Test Example",
                               phone1: "(12)1212-1212",
                               city_id: @curitiba.id,
                               rg: "1234567")

        @account = Account.new(uid: @citizen.cpf,
                               password: "123mudar",
                               password_confirmation: "123mudar")

        @citizen.active = true
        @citizen.account_id = @account.id
      end

      it "should return an error" do
        @citizen.save
        assert_not_empty @citizen.errors.messages[:cpf]
      end

      it "should not save" do
        assert_not @citizen.save
      end
    end

    describe "Missing city" do
      before do

        @citizen = Citizen.new(birth_date: "Apr 18 1997",
                               cep: "81530110",
                               email: "test@example.com",
                               name: "Test Example",
                               phone1: "(12)1212-1212",
                               rg: "1234567")

        @account = Account.new(uid: @citizen.cpf,
                               password: "123mudar",
                               password_confirmation: "123mudar")

        @citizen.active = true
        @citizen.account_id = @account.id
      end

      it "should return an error" do
        @citizen.save
        assert_not_empty @citizen.errors.messages[:city]
      end

      it "should not save" do
        assert_not @citizen.save
      end
    end

    describe "Missing city" do
      before do
        @citizen = Citizen.new(birth_date: "Apr 18 1997",
                               cep: "81530110",
                               email: "test@example.com",
                               name: "Test Example",
                               phone1: "(12)1212-1212",
                               rg: "1234567")
        @account = Account.new(uid: @citizen.cpf,
                               password: "123mudar",
                               password_confirmation: "123mudar")
        @citizen.active = true
        @citizen.account_id = @account.id
      end

      it "should return an error" do
        @citizen.save
        assert_not_empty @citizen.errors.messages[:cpf]
      end

      it "should not save" do
        assert_not @citizen.save
      end
    end

    describe "Invalid cpf" do
      before do
        @citizen = Citizen.new(cpf: "11111111111",
                               birth_date: "Apr 18 1997",
                               cep: "81530110",
                               email: "test@example.com",
                               name: "Test Example",
                               phone1: "(12)1212-1212",
                               rg: "1234567")
        @account = Account.new(uid: @citizen.cpf,
                               password: "123mudar",
                               password_confirmation: "123mudar")
        @citizen.active = true
        @citizen.account_id = @account.id
      end

      it "should return an error" do
        @citizen.save
        assert_not_empty @citizen.errors.messages[:cpf]
      end

      it "should not save" do
        assert_not @citizen.save
      end
    end

    describe "Missing birth date" do
      before do
        @citizen = Citizen.new(cpf: "10845922904",
                               cep: "81530110",
                               email: "test@example.com",
                               name: "Test Example",
                               phone1: "(12)1212-1212",
                               rg: "1234567")
        @account = Account.new(uid: @citizen.cpf,
                               password: "123mudar",
                               password_confirmation: "123mudar")
        @citizen.active = true
        @citizen.account_id = @account.id
      end

      it "should return an error" do
        @citizen.save
        assert_not_empty @citizen.errors.messages[:birth_date]
      end

      it "should not save" do
        assert_not @citizen.save
      end
    end

    describe "Missing cep" do
      before do
        @citizen = Citizen.new(cpf: "10845922904",
                               birth_date: "Apr 18 1997",
                               email: "test@example.com",
                               name: "Test Example",
                               phone1: "(12)1212-1212",
                               rg: "1234567")
        @account = Account.new(uid: @citizen.cpf,
                               password: "123mudar",
                               password_confirmation: "123mudar")
        @citizen.active = true
        @citizen.account_id = @account.id
      end

      it "should return an error" do
        @citizen.save
        assert_not_empty @citizen.errors.messages[:cep]
      end

      it "should not save" do
        assert_not @citizen.save
      end
    end

    describe "Missing name" do
      before do
        @citizen = Citizen.new(cpf: "10845922904",
                               birth_date: "Apr 18 1997",
                               cep: "81530110",
                               email: "test@example.com",
                               phone1: "(12)1212-1212",
                               rg: "1234567")
        @account = Account.new(uid: @citizen.cpf,
                               password: "123mudar",
                               password_confirmation: "123mudar")
        @citizen.active = true
        @citizen.account_id = @account.id
      end

      it "should return an error" do
        @citizen.save
        assert_not_empty @citizen.errors.messages[:name]
      end

      it "should not save" do
        assert_not @citizen.save
      end
    end

    describe "Missing phone" do
      before do
        @citizen = Citizen.new(cpf: "10845922904",
                               birth_date: "Apr 18 1997",
                               cep: "81530110",
                               email: "test@example.com",
                               name: "Test Example",
                               rg: "1234567")
        @account = Account.new(uid: @citizen.cpf,
                               password: "123mudar",
                               password_confirmation: "123mudar")
        @citizen.active = true
        @citizen.account_id = @account.id
      end

      it "should return an error" do
        @citizen.save
        assert_not_empty @citizen.errors.messages[:phone1]
      end

      it "should not save" do
        assert_not @citizen.save
      end
    end

    describe "Missing rg" do
      before do
        @citizen = Citizen.new(cpf: "10845922904",
                               birth_date: "Apr 18 1997",
                               cep: "81530110",
                               email: "test@example.com",
                               name: "Test Example",
                               phone1: "(12)1212-1212")
        @account = Account.new(uid: @citizen.cpf,
                               password: "123mudar",
                               password_confirmation: "123mudar")
        @citizen.active = true
        @citizen.account_id = @account.id
      end

      it "should return an error" do
        @citizen.save
        assert_not_empty @citizen.errors.messages[:rg]
      end

      it "should not save" do
        assert_not @citizen.save
      end
    end
  end
end
