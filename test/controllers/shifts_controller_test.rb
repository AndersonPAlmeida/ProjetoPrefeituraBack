require 'test_helper'

class ShiftsControllerTest < ActionDispatch::IntegrationTest
  let(:shift) { shifts :one }

  it "gets index" do
    get shifts_url
    value(response).must_be :success?
  end

  it "creates shift" do
    expect {
      post shifts_url, params: { shift: {  } }
    }.must_change "Shift.count"

    value(response.status).must_equal 201
  end

  it "shows shift" do
    get shift_url(shift)
    value(response).must_be :success?
  end

  it "updates shift" do
    patch shift_url(shift), params: { shift: {  } }
    value(response.status).must_equal 200
  end

  it "destroys shift" do
    expect {
      delete shift_url(shift)
    }.must_change "Shift.count", -1

    value(response.status).must_equal 204
  end
end
