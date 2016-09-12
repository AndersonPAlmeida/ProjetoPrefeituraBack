require "test_helper"

describe Sector do
  let(:sector) { Sector.new }

  it "must be valid" do
    value(sector).must_be :valid?
  end
end
