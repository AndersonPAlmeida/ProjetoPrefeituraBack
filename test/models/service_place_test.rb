require "test_helper"

class ServicePlaceTest < ActiveSupport::TestCase
  describe ServicePlace do
    describe "Sucessful service place test" do
      before do
        @service_place = ServicePlace.new(address_number: "10",
                               address_street: "Faker Street", 
                               name: "Faker's City Hall", 
                               neighborhood: "Faker's Neighborhood")
      end

      it "should work fine" do
	  assert @service_place.save!
      end
    end
  end
end
