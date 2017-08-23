class DependantSerializer < ActiveModel::Serializer
  attributes :id, 
    :deactivated

  belongs_to :citizen
end
