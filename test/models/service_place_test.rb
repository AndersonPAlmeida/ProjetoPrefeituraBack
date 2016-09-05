require "test_helper"

class ServicePlaceTest < ActiveSupport::TestCase
  describe ServicePlace do
    describe "City Hall missing" do
      before do
        @service_place = ServicePlace.new(address_number: "10",
                               address_street: "Faker Street", 
                               name: "Faker's City Hall", 
                               neighborhood: "Faker's Neighborhood")
      end

      it "should return an error" do
	  assert_not @service_place.save
	  assert_not_empty @service_place.errors.messages[:city_hall]
      end
    end
  end
end
