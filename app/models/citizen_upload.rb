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
