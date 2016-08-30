require "test_helper"

class ProfessionalTest < ActiveSupport::TestCase
  describe Professional do
    describe "Sucessful professional test" do
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
        @professional = Professional.new(registration: "123")
        @professional.account_id = @account.id
      end

      it "should work fine" do
	  assert @professional.save!
      end
    end
  end
end
