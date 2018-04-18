class CitizenUpload < ApplicationRecord
  belongs_to :citizen

  # Specify location where the log should be stored (default is public)
  has_attached_file :log,
    path: "/data/citizen_upload/:id/log.csv"

  # Validates format of logs
  validates_attachment_content_type :log,
    :content_type => ["text/plain", "text/csv"]

end
