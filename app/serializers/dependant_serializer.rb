class DependantSerializer < ActiveModel::Serializer
  attributes :id, 
    :active, 
    :deactivated

  belongs_to :citizen
end
