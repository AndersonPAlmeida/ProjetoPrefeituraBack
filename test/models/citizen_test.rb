require "test_helper"

class CitizenTest < ActiveSupport::TestCase
  describe Citizen do
    describe "Missing cpf" do
      before do
        @citizen = Citizen.new(birth_date: "Apr 18 1997", 
                               cep: "1234567", 
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
        @citizen = Citizen.new(cpf: "12345678910",
                               cep: "1234567", 
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
        @citizen = Citizen.new(cpf: "12345678910",
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
        @citizen = Citizen.new(cpf: "12345678910",
                               birth_date: "Apr 18 1997", 
                               cep: "1234567", 
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
        @citizen = Citizen.new(cpf: "12345678910",
                               birth_date: "Apr 18 1997", 
                               cep: "1234567",
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
        @citizen = Citizen.new(cpf: "12345678910",
                               birth_date: "Apr 18 1997", 
                               cep: "1234567",
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
