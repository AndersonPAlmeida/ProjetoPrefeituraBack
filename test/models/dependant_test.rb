require "test_helper"

describe Dependant do
  let(:dependant) { Dependant.new }

  it "must be valid" do
    value(dependant).must_be :valid?
  end
end
