require 'test_helper'

class SchedulesControllerTest < ActionDispatch::IntegrationTest
  let(:schedule) { schedules :one }

  it "gets index" do
    get schedules_url
    value(response).must_be :success?
  end

  it "creates schedule" do
    expect {
      post schedules_url, params: { schedule: {  } }
    }.must_change "Schedule.count"

    value(response.status).must_equal 201
  end

  it "shows schedule" do
    get schedule_url(schedule)
    value(response).must_be :success?
  end

  it "updates schedule" do
    patch schedule_url(schedule), params: { schedule: {  } }
    value(response.status).must_equal 200
  end

  it "destroys schedule" do
    expect {
      delete schedule_url(schedule)
    }.must_change "Schedule.count", -1

    value(response.status).must_equal 204
  end
end
