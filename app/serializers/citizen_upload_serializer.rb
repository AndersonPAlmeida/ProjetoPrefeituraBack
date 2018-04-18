class CitizenUploadSerializer < ActiveModel::Serializer
  attributes :id,
    :citizen_id,
    :amount,
    :status,
    :status_string,
    :progress,
    :created_at,
    :updated_at

  def status_string
    # Check if status is "Ready to start"
    if object.status == 0
      return "Ready to start"
    # Check if status is "In progress"
    elsif object.status == 1
      return "In progress"
    # Check if status is "Completed"
    elsif object.status == 2
      return "Completed"
    # Check if status is "Completed with errors"
    elsif object.status == 3
      return "Completed with errors"
    end

    return "Undefined"
  end
end
