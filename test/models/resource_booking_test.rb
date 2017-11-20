require "test_helper"

describe ResourceBooking do
  let(:resource_booking) { ResourceBooking.new }

  it "must be valid" do
    value(resource_booking).must_be :valid?
  end
end
