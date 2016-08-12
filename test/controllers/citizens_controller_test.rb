require 'test_helper'

class Api::V1::CitizensControllerTest < ActionDispatch::IntegrationTest
  before do
    @citizen ||= Citizen.new
    @account ||= Account.new
    @citizen.address_complement = nil 
    @citizen.address_number = nil
    @citizen.address_street = nil
    @citizen.birth_date = "18/04/1997"
    @citizen.cep = "1234567"
    @citizen.cpf = "123.456.789-10"
    @citizen.email = "asdasd@asdasd.com"
    @citizen.name = "Asdasd"
    @citizen.neighborhood = nil
    @citizen.note = nil
    @citizen.pcd = nil
    @citizen.phone1 = "123123123"
    @citizen.phone2 = nil
    @citizen.photo_content_type = nil
    @citizen.photo_file_name = nil
    @citizen.photo_file_size = nil
    @citizen.photo_update_at = nil
    @citizen.rg = "1233456"
    @account.password = "123mudar"
    @account.password_confirmation = "123mudar"
  end

  def test_index
    get '/v1/citizens'
    assert_response :success
  end

  def test_create
    assert_difference('Account.count') do
      assert_difference('Citizen.count') do
        post '/v1/auth', params: {
          password: @account.password,
          password_confirmation: @account.password_confirmation,
          address_complement: @citizen.address_complement,
          address_number: @citizen.address_number,
          address_street: @citizen.address_street,
          birth_date: @citizen.birth_date,
          cep: @citizen.cep,
          cpf: @citizen.cpf,
          email: @citizen.email, 
          name: @citizen.name,
          neighborhood: @citizen.neighborhood, 
          note: @citizen.note, 
          pcd: @citizen.pcd, 
          phone1: @citizen.phone1, 
          phone2: @citizen.phone2, 
          photo_content_type: @citizen.photo_content_type, 
          photo_file_name: @citizen.photo_file_name, 
          photo_file_size: @citizen.photo_file_size, 
          photo_update_at: @citizen.photo_update_at, 
          rg: @citizen.rg 
        } 
      end
    end

    assert_response 200
  end

  def test_show
    auth_request(@account)
    get '/v1/citizens'
    assert_response :success
  end

  def test_update
    patch citizen_url(citizen), params: { 
      citizen: { address_complement: @citizen.address_complement, 
                 address_number: @citizen.address_number, 
                 address_street: @citizen.address_street, 
                 birth_date: @citizen.birth_date, 
                 cep: @citizen.cep, 
                 cpf: @citizen.cpf, 
                 email: @citizen.email, 
                 name: @citizen.name, 
                 neighborhood: @citizen.neighborhood, 
                 note: @citizen.note, 
                 pcd: @citizen.pcd, 
                 phone1: @citizen.phone1, 
                 phone2: @citizen.phone2, 
                 photo_content_type: @citizen.photo_content_type, 
                 photo_file_name: @citizen.photo_file_name, 
                 photo_file_size: @citizen.photo_file_size, 
                 photo_update_at: @citizen.photo_update_at, 
                 rg: @citizen.rg } }
    assert_response 200
  end

  def test_destroy
    assert_difference('Citizen.count', -1) do
      delete citizen_url(@citizen)
    end

    assert_response 204
  end
end
