require "test_helper"

class ServicePlaceTest < ActiveSupport::TestCase
  def service_place
    @service_place ||= ServicePlace.new
  end

  def test_valid
    assert service_place.valid?
  end
end
