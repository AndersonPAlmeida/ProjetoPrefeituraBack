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

class EmailValidator < ActiveModel::EachValidator

  # regular expression to describe a valid email
  EMAIL_REGEX = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/

  # Validate email, if not valid put an error message in
  # the record.errors[attribute]
  # @param record [ApplicationRecord] the model which owns the email
  # @param attribute [Symbol] the attribute to be validated (email)
  # @param value [String] the value of the record's email
  def validate_each(record, attribute, value)
    unless EMAIL_REGEX.match(value)
      # record.errors[attribute] << ("#{value} is invalid.")
      record.errors[attribute] << ("#{value} é inválido!")
    end
  end
end
