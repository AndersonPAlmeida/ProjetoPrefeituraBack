require 'test_helper'

class SectorsControllerTest < ActionDispatch::IntegrationTest
  let(:sector) { sectors :one }

  it "gets index" do
    get sectors_url
    value(response).must_be :success?
  end

  it "creates sector" do
    expect {
      post sectors_url, params: { sector: {  } }
    }.must_change "Sector.count"

    value(response.status).must_equal 201
  end

  it "shows sector" do
    get sector_url(sector)
    value(response).must_be :success?
  end

  it "updates sector" do
    patch sector_url(sector), params: { sector: {  } }
    value(response.status).must_equal 200
  end

  it "destroys sector" do
    expect {
      delete sector_url(sector)
    }.must_change "Sector.count", -1

    value(response.status).must_equal 204
  end
end
