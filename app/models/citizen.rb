class Citizen < ApplicationRecord

  # Associations #
  belongs_to :account
  belongs_to :city
  belongs_to :citizen, optional: true, foreign_key: :responsible_id, class_name: "Citizen"
  has_one :dependant

  # Validations #
  validates :cpf, cpf: true
  validates :email, email: true, allow_blank: true

  validates_presence_of :cpf
  validates_presence_of :name
  validates_presence_of :birth_date
  validates_presence_of :rg
  validates_presence_of :cep
  validates_presence_of :phone1

  validates_uniqueness_of :cpf

  validates_length_of :name, maximum: 255
  validates_length_of :rg, maximum: 13
  validates_length_of :address_number, within: 0..10, allow_blank: true

  validates_numericality_of :address_number, only_integer: true, 
    allow_blank: true

  validates_format_of       :name,
    with: /\A[^0-9`!@#\$%\^&*+_=]+\z/

  validates_inclusion_of    :active, in: [true, false]

  has_attached_file :avatar,
    path: "images/citizens/:id/avatar_:style.:extension",
    styles: { 
      large: '500x500', 
      medium: '300x300', 
      thumb: '100x100' 
    }

  validates_attachment_content_type :avatar,
    :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

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
      :avatar,
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

  # @return [ActiveRecord_Relation] every active citizen
  def self.all_active
    Citizen.where(active: true, responsible_id: nil)
  end

  # @param city_id [Integer] the id of the city for querying local citizens
  # @return [ActiveRecord_Relation] every citizen registered with the city_id
  def self.local_active(city_id)
    Citizen.all_active.where(city_id: city_id)
  end

  # Used in menu to choose citizen to schedule for in the scheduling process
  # @return [ActiveRecord_Relation] citizen's dependants and himself
  def schedule_response
    Citizen.where('id = ? OR responsible_id = ?', self.id, self.id)
      .as_json(only: [:id, :name, :birth_date, :cpf, :rg])
  end

  # @return [ActiveRecord_Relation] citizen's dependants
  def dependants
    Citizen.where(responsible_id: self.id)
  end
end
