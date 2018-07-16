class CitizenUpload < ApplicationRecord
  include Searchable

  belongs_to :citizen

  # Specify location where the log should be stored (default is public)
  has_attached_file :log,
    path: "/data/citizen_upload/:id/log.csv"

  # Do not validate format of logs
  do_not_validate_attachment_file_type :log

  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @params permission [String] Permission of current user
  # @return [ActiveRecords] filtered citizens
  def self.filter(params, npage, permission)
    return search(search_params(params, permission), npage)
  end

  # Translates incoming search parameters to ransack patterns
  # @params params [ActionController::Parameters] Parameters for searching
  # @params permission [String] Permission of current user
  # @return [Hash] filtered and translated parameters
  def self.search_params(params, permission)
    sortable = ["created_at"]
    filter = {"citizen_id" => "citizen_id_eq", "created_at" => "created_at_gteq"}

    return filter_search_params(params, filter, sortable)
  end

end
