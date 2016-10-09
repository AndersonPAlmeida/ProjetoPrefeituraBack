class Citizen < ApplicationRecord

  # Associations #
  belongs_to :account
  belongs_to :city
  has_one    :dependant

  belongs_to :citizen, optional: true, :foreign_key => :responsible_id,
             :class_name => "Citizen"

  # Validations #
  validates :cpf, cpf: true
  validates :email, email: true, allow_blank: true

  validates_presence_of   :cpf
  validates_presence_of   :name
  validates_presence_of   :birth_date
  validates_presence_of   :rg
  validates_presence_of   :cep
  validates_presence_of   :phone1

  validates_uniqueness_of   :cpf

  validates_length_of       :name, maximum: 255
  validates_length_of       :rg, maximum: 13
  validates_length_of       :address_number, within: 0..10,
                             allow_blank: true

  validates_numericality_of :address_number,
                             only_integer: true,
                             allow_blank: true

  validates_format_of       :name,
                             with: /\A[^0-9`!@#\$%\^&*+_=]+\z/

  validates_inclusion_of    :active, in: [true, false]

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
      :photo_content_type,
      :photo_file_name,
      :photo_file_size,
      :photo_update_at,
      :rg
    ]
  end

  # @return all active citizens
  def self.all_active
    Citizen.where(active: true)
  end
end
