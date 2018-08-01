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

class CpfValidator < ActiveModel::EachValidator

  # regular expression to describe a valid cpf
  CPF_REGEX = /^[0-9]{11}$/

  # Validate cpf, if not valid send an error message to
  # the record.errors[attribute]
  # @param record [ApplicationRecord] the model which owns a cpf
  # @param attribute [Symbol] the attribute to be validated (cpf)
  # @param value [String] the value of the record's cpf
  def validate_each(record, attribute, value)
    unless CpfValidator.validate_cpf(value) 
      record.errors[attribute] << ("#{value} is invalid.")
    end
  end

  # @return [boolean] true if cpf is valid
  # @param cpf [String] the cpf to be validated
  def self.validate_cpf(cpf)

    # check if is in the right format
    unless CPF_REGEX.match(cpf)
      return false
    end

    # replace every non numeric char with blank
    if !cpf.nil?
      number = cpf.gsub(/[^0-9]/, '')
    end

    arr = number.to_s.chars.map(&:to_i)
    # cpf with all digits the same should not be valid, i.e. 11111111111
    if arr.count(arr[0]) == arr.size || arr.size != 11
      return false
    end

    # return true if the 10th and the 11th digit are valid
    return (check(10, arr) and check(11, arr))
  end

  private

  # @return [boolean] true if last two digits are valid
  # @param aux [Fixnum] the auh-th number to be validated (10 or 11)
  # @param arr [Array] the array with individual cpf numbers
  def self.check(aux, arr)
    sum = 0
    aux.downto(2).to_a.zip(arr.each) { |i, j| sum += j * i }
    return (((sum * 10) % 11) % 10 == arr[aux - 12])
  end
end
