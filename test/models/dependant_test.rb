require "test_helper"

class DependantTest < ActiveSupport::TestCase
  describe Dependant do
    describe "Sucessful dependant test" do
      before do
        @citizen = Citizen.new(cpf: "10845922904",
                               birth_date: "Apr 18 1997", 
                               cep: "1234567", 
                               email: "test@example.com",
                               name: "Test Example",
                               phone1: "(12)1212-1212",
                               rg: "1234567")
        @account = Account.new(uid: @citizen.cpf,
                               password: "123mudar",
                               password_confirmation: "123mudar")

	@account.save!
        @citizen.active = true
        @citizen.account_id = @account.id
	@citizen.save!
        @dependant = Dependant.new 
        @dependant.citizen_id = @citizen.id
      end

      it "should work fine" do
	  assert @dependant.save!
      end
    end
  end
end
