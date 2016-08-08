require 'test_helper'

class CitizensControllerTest < ActionDispatch::IntegrationTest
  def citizen
    @citizen ||= citizens :one
  end

  def test_index
    get citizens_url
    assert_response :success
  end

  def test_create
    assert_difference('Citizen.count') do
      post citizens_url, params: { 
        citizen: { address_complement: citizen.address_complement,
                   address_number: citizen.address_number,
                   address_street: citizen.address_street,
                   birth_date: citizen.birth_date,
                   cep: citizen.cep,
                   cpf: citizen.cpf,
                   email: citizen.email, 
                   name: citizen.name, 
                   neighborhood: citizen.neighborhood, 
                   note: citizen.note, 
                   pcd: citizen.pcd, 
                   phone1: citizen.phone1, 
                   phone2: citizen.phone2, 
                   photo_content_type: citizen.photo_content_type, 
                   photo_file_name: citizen.photo_file_name, 
                   photo_file_size: citizen.photo_file_size, 
                   photo_update_at: citizen.photo_update_at, 
                   rg: citizen.rg } }
    end

    assert_response 201
  end

  def test_show
    get citizen_url(citizen)
    assert_response :success
  end

  def test_update
    patch citizen_url(citizen), params: { 
      citizen: { address_complement: citizen.address_complement, 
                 address_number: citizen.address_number, 
                 address_street: citizen.address_street, 
                 birth_date: citizen.birth_date, 
                 cep: citizen.cep, 
                 cpf: citizen.cpf, 
                 email: citizen.email, 
                 name: citizen.name, 
                 neighborhood: citizen.neighborhood, 
                 note: citizen.note, 
                 pcd: citizen.pcd, 
                 phone1: citizen.phone1, 
                 phone2: citizen.phone2, 
                 photo_content_type: citizen.photo_content_type, 
                 photo_file_name: citizen.photo_file_name, 
                 photo_file_size: citizen.photo_file_size, 
                 photo_update_at: citizen.photo_update_at, 
                 rg: citizen.rg } }
    assert_response 200
  end

  def test_destroy
    assert_difference('Citizen.count', -1) do
      delete citizen_url(citizen)
    end

    assert_response 204
  end
end
