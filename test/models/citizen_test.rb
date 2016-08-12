require "test_helper"

class CitizenTest < ActiveSupport::TestCase
  def citizen
    @citizen ||= Citizen.new
  end

  def test_valid
    assert citizen
  end
end
