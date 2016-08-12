require 'test_helper'

class ProfessionalsControllerTest < ActionDispatch::IntegrationTest
  def professional
    @professional ||= professionals :one
  end

  def test_index
    get professionals_url
    assert_response :success
  end

  def test_create
    assert_difference('Professional.count') do
      post professionals_url, params: { professional: {  } }
    end

    assert_response 201
  end

  def test_show
    get professional_url(professional)
    assert_response :success
  end

  def test_update
    patch professional_url(professional), params: { professional: {  } }
    assert_response 200
  end

  def test_destroy
    assert_difference('Professional.count', -1) do
      delete professional_url(professional)
    end

    assert_response 204
  end
end
