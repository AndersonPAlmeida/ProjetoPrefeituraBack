class CityHall < ApplicationRecord
  include Searchable

  # Associations #
  has_many :service_places
  has_many :resource_type
  belongs_to :city

  # Validations #
  validates_presence_of :name,
    :cep,
    :neighborhood,
    :address_street,
    :address_number,
    :city_id,
    :phone1,
    :schedule_period

  validates_presence_of :block_text, if: :citizen_access_blocked?

  validates_uniqueness_of :city_id

  validates_inclusion_of :active, in: [true, false]

  validates_inclusion_of :citizen_access,
    :citizen_register, in: [true, false]

  validates_numericality_of :schedule_period,
    greater_than: 0, less_than_or_equal_to: 2000000000

  validates_length_of :phone1,
    :phone2, maximum: 14

  validates_length_of :name,
    :neighborhood,
    :address_street,
    :address_complement, maximum: 255

  validates_length_of :address_number, maximum: 10, allow_blank: true

  # Specify location where the picture should be stored (default is public)
  # and the formats (large, medium, thumb)
  has_attached_file :avatar,
    path: "images/city_halls/:id/avatar_:style.:extension",
    styles: { large: '500x500', medium: '300x300', thumb: '100x100' }

  # Validates format of pictures
  validates_attachment_content_type :avatar,
    :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  before_validation :create_city_hall

  scope :all_active, -> {
    where(active: true)
  }


  # Returns json response to index city_halls
  # @return [Json] response
  def self.index_response
    self.all.as_json(only: [:id, :name, :cep, :active, :state, :city])
  end


  # @return [Json] detailed city_hall's data
  def complete_info_response
    city = City.find(self.city_id)
    state = city.state
    address = Address.get_address(self.cep)

    return self.as_json(only: [
        :id, :active, :address_number, :block_text,
        :citizen_access, :citizen_register, :name,
        :schedule_period, :address_complement, :description,
        :email, :phone1, :phone2, :support_email,
        :show_professional, :url
      ])
      .merge({city: city.as_json(except: [
        :ibge_code, :state_id, :created_at, :updated_at
      ])})
      .merge({state: state.as_json(except: [
        :ibge_code, :created_at, :updated_at
      ])})
      .merge({address: address.as_json(except: [
        :created_at, :updated_at, :state_id, :city_id
      ])})
  end


  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @params permission [String] Permission of current user
  # @return [ActiveRecords] filtered service_places
  def self.filter(params, npage, permission)
    return search(search_params(params, permission), npage)
  end


  private

  # Translates incoming search parameters to ransack patterns
  # @params params [ActionController::Parameters] Parameters for searching
  # @params permission [String] Permission of current user
  # @return [Hash] filtered and translated parameters
  def self.search_params(params, permission)
    case permission
    when "adm_c3sl"
      sortable = ["name", "cep", "active", "city_name", "city_state_name"]
      filter = {"name" => "name_cont", "city" => "city_name_cont",
                "state" => "city_state_name_cont", "s" => "s"}
    end

    return filter_search_params(params, filter, sortable)
  end


  # @return [boolean] check if citizen can access city hall
  def citizen_access_blocked?
    !self.citizen_access
  end


  # Method surrounding create method for CityHall. It associates
  # the address to the city hall given a cep
  def create_city_hall
    address = Address.get_address(self.cep)

    self.active = true
    if not address.nil?
      self.city_id = address.city_id
      self.address_street = address.address
      self.neighborhood = address.neighborhood
    else
      self.errors["cep"] << "#{self.cep} is invalid."
      return false
    end
  end
end
