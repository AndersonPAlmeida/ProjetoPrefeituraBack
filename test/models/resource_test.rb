require "test_helper"

describe Resource do
  let(:resource) { Resource.new }

  it "must be valid" do
    value(resource).must_be :valid?
  end
end
