require "test_helper"

describe Schedule do
  let(:schedule) { Schedule.new }

  it "must be valid" do
    value(schedule).must_be :valid?
  end
end
