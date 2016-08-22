require 'test_helper'

class ServicePlacesControllerTest < ActionDispatch::IntegrationTest
  def service_place
    @service_place ||= service_places :one
  end

  def test_index
    get service_places_url
    assert_response :success
  end

  def test_create
    assert_difference('ServicePlace.count') do
      post service_places_url, params: { service_place: {  } }
    end

    assert_response 201
  end

  def test_show
    get service_place_url(service_place)
    assert_response :success
  end

  def test_update
    patch service_place_url(service_place), params: { service_place: {  } }
    assert_response 200
  end

  def test_destroy
    assert_difference('ServicePlace.count', -1) do
      delete service_place_url(service_place)
    end

    assert_response 204
  end
end
