# This file is part of Agendador.
#
# Agendador is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Agendador is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Agendador.  If not, see <https://www.gnu.org/licenses/>.

class Citizen < ApplicationRecord
  include Searchable

  # Associations #
  belongs_to :account, optional: true
  belongs_to :city
  belongs_to :citizen, optional: true, foreign_key: :responsible_id, class_name: "Citizen"
  has_one :dependant
  has_many :resource_booking

  # Validations #
  validates :cpf, cpf: true, if: :cpf_required?
  validates :email, email: true, allow_blank: true
  validates :address_street, presence: true, allow_blank: false
  validates :address_number, presence: true, allow_blank: false

  validates_presence_of :cpf, if: :cpf_required?
  validates_presence_of :name
  validates_presence_of :birth_date
  validates_presence_of :rg, :cep, :phone1, if: :cpf_required?

  validates_uniqueness_of :cpf, if: :cpf_required?

  validates_length_of :name, maximum: 255
  validates_length_of :rg, maximum: 13
  validates_length_of :address_number, within: 0..10, allow_blank: true

  validates_numericality_of :address_number, only_integer: true,
    allow_blank: true

  validates_format_of       :name,
    with: /\A[^0-9`!@#\$%\^&*+_=]+\z/

  validates_inclusion_of    :active, in: [true, false]

  # Specify location where the picture should be stored (default is public)
  # and the formats (large, medium, thumb)
  has_attached_file :avatar,
    path: "images/citizens/:id/avatar_:style.:extension",
    styles: { large: '500x500', medium: '300x300', thumb: '100x100' }

  # Validates format of pictures
  validates_attachment_content_type :avatar,
    :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  before_create :set_address
  before_save :set_address

  before_validation :set_address

  # Scopes #
  scope :all_active, -> {
    where(active: true, responsible_id: nil)
  }

  scope :local, ->(city_id) {
    where(city_id: city_id)
  }

  scope :dependants, -> {
    where(responsible_id: self.id)
  }


  # @return list of citizen's columns
  def self.keys
    return [
      :active,
      :address_complement,
      :address_number,
      :address_street,
      :birth_date,
      :cep,
      :city_id,
      :cpf,
      :email,
      :name,
      :neighborhood,
      :note,
      :pcd,
      :phone1,
      :phone2,
      #:avatar,
      :rg
    ]
  end


  # @return citizen's professional data
  def professional
    if self.account
      self.account.professional
    else
      nil
    end
  end


  # @return [Integer] number of dependants of a citizen
  def num_of_dependants
    return Citizen.where(responsible_id: self.id).count
  end


  # Used when the city, state and address are necessary (sign_in, show,
  # dependant show...)
  # @return [Json] detailed citizen's data
  def complete_info_response
    city = self.city
    state = city.state

    address = {
      zipcode: self.cep,
      address: self.address_street,
      neighborhood: self.neighborhood,
      complement: self.address_complement
    }

    return self.as_json(except: [:city_id, :created_at, :updated_at])
      .merge({city: city.as_json(except: [
        :ibge_code, :state_id, :created_at, :updated_at
      ])})
      .merge({state: state.as_json(except: [
        :ibge_code, :created_at, :updated_at
      ])})
      .merge({address: address})
  end


  # @return [Json] detailed citizen's data
  def partial_info_response
    city = self.city
    state = city.state

    address = Address.get_address(self.cep)

    return self.as_json(except: [:city_id, :created_at, :updated_at])
      .merge({city: city.as_json(except: [
        :ibge_code, :state_id, :created_at, :updated_at
      ])})
      .merge({state: state.as_json(except: [
        :ibge_code, :created_at, :updated_at
      ])})
  end


  # Used in menu to choose citizen to schedule for in the scheduling process
  # @return [ActiveRecord_Relation] citizen's dependants and himself
  def schedule_response
    Citizen.where('id = ? OR responsible_id = ?', self.id, self.id)
      .as_json(only: [:id, :name, :birth_date, :cpf, :rg])
  end


  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @params permission [String] Permission of current user
  # @return [ActiveRecords] filtered citizens
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
      sortable = ["name", "cpf", "birth_date"]
      filter = {"name" => "name_cont", "cpf" => "cpf_eq", "city_id" => "city_id_eq", "s" => "s"}
    when "adm_prefeitura"
      sortable = ["name", "cpf", "birth_date"]
      filter = {"name" => "name_cont", "cpf" => "cpf_eq", "s" => "s"}
    end

    return filter_search_params(params, filter, sortable)
  end


  # @return [Boolean] true if cpf is required (isn't a dependant) false if it is
  # not (is a dependant)
  def cpf_required?
    self.responsible_id.nil?
  end


  # Callback method for attributing correct address to citizen given CEP
  # @return [Boolean] true if provided CEP is correct, false otherwise
  def set_address
    if self.cep.nil? or self.cep.empty?
      self.errors["cep"] << "Cep can't be blank."
      return false
    end

    address = Address.get_address(self.cep)

    if not address.nil?
      self.city_id = address.city_id

      if not address.address.empty?
        self.address_street = address.address
      end

      if not address.number.nil?
        self.address_number = address.number
      end

      if not address.neighborhood.empty?
        self.neighborhood = address.neighborhood
      end
    else
      self.errors["cep"] << "#{self.cep} is invalid."
      return false
    end
  end
end
