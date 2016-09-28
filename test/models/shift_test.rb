require "test_helper"

describe Shift do
  let(:shift) { Shift.new }

  it "must be valid" do
    value(shift).must_be :valid?
  end
end
