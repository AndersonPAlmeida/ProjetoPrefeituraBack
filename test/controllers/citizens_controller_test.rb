require 'test_helper'
#require 'minitest/spec'
#require 'minitest/autorun'

class Api::V1::CitizensControllerTest < ActionDispatch::IntegrationTest
  before do
    @citizen = Citizen.new(cpf: "123.456.789-04", 
                         birth_date: "18/04/1997", 
                         cep: "1234567", 
                         email: "test@example.com",
                         name: "Test Example", 
                         phone1: "(12)1212-1212",
                         rg: "1234567")
    @account = Account.new(uid: @citizen.cpf,
                         password: "123mudar",
                         password_confirmation: "123mudar")
    @account.save!
    @citizen.account_id = @account.id
    @citizen.save!
  end

  #test "index" do
  #  get '/v1/citizens'
  #  assert_response :success
  #end
end
