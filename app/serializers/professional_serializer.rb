class ProfessionalSerializer < ActiveModel::Serializer
  ActiveModelSerializers.config.default_includes = '**'
  attributes :id, 
             :active,
             :registration

  has_one :citizen, through: :account
  has_one :occupation
end
