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

class CepValidator < ActiveModel::EachValidator

  # regular expression to describe a valid cep
  CEP_REGEX = /^[0-9]{8}$/

  # Validate cep, if not valid put an error message in
  # the record.errors[attribute]
  # @param record [ApplicationRecord] the model which owns the cep
  # @param attribute [Symbol] the attribute to be validated (cep)
  # @param value [String] the value of the record's cep
  def validate_each(record, attribute, value)
    unless valid_format?(value)
      # record.errors[attribute] << ("#{value} is invalid.")
      record.errors[attribute] << ("#{value} é inválido!")
    end
  end

  # Finds address corresponding to cep
  # @param cep [String] cep number
  # @return [Json] json containing address information
  def self.get_address(cep)
    Agendador::CEP::Finder.get(cep)
  end

  # Check if cep is in the right format
  # @param cep [String] cep number
  # @return [Boolean] cep corresponds to CEP_REGEX
  def self.valid_format?(cep)
    CEP_REGEX.match(cep)
  end
end
