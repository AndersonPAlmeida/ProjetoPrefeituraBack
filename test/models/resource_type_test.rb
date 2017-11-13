require "test_helper"

describe ResourceType do
  let(:resource_type) { ResourceType.new }

  it "must be valid" do
    value(resource_type).must_be :valid?
  end
end
