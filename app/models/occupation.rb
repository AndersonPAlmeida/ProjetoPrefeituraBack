class Occupation < ApplicationRecord
  include Searchable

  # Associations #
  has_many   :professionals
  belongs_to :city_hall

  # Validations #
  validates_presence_of  :name, :description, :city_hall_id
  validates_inclusion_of :active, in: [true,false]
  validates_format_of    :name, with: /\A[^0-9`!@#\$%\^&*+_=]+\z/

  scope :all_active, -> { 
    where(active: true) 
  }

  scope :local_city_hall, -> (city_hall_id) { 
    where(city_hall_id: city_hall_id)
  }

  delegate :name, to: :city_hall, prefix: true


  # @return [Json] detailed occupation's data
  def complete_info_response
    return self.as_json(only: [
       :id, :name, :active, :description, :city_hall_id
      ], methods: %w(city_hall_name))
  end


  # Returns json response to index occupations
  # @return [Json] occupations
  def self.index_response
    self.all.as_json(only: [
      :id, :name, :description, :active
    ], methods: %w(city_hall_name))
  end


  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @params permission [String] Permission of current user
  # @return [ActiveRecords] filtered occupations
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
      sortable = ["name", "description", "active"]
      filter = {"name" => "name_cont", "active" => "active_eq", 
                "description" => "description_cont",
                "city_hall_id" => "city_hall_id_eq",
                "s" => "s"}

    when "adm_prefeitura"
      sortable = ["name", "description", "active"]
      filter = {"name" => "name_cont", "active" => "active_eq", 
                "description" => "description_cont",
                "s" => "s"}

    end

    return filter_search_params(params, filter, sortable) 
  end
end
