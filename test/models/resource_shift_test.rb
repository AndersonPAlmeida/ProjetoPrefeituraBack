require "test_helper"

describe ResourceShift do
  let(:resource_shift) { ResourceShift.new }

  it "must be valid" do
    value(resource_shift).must_be :valid?
  end
end
