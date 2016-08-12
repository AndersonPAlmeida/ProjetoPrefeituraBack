require "test_helper"

class ProfessionalTest < ActiveSupport::TestCase
  def professional
    @professional ||= Professional.new
  end

  def test_valid
    assert professional.valid?
  end
end
