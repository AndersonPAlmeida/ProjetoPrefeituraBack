class CpfValidator < ActiveModel::EachValidator

  # regular expression to describe a valid cpf
  CPF_REGEX = /^[0-9]{11}$/

  # Validate cpf, if not valid send an error message to
  # the record.errors[attribute]
  # @param record [ApplicationRecord] the model which owns a cpf
  # @param attribute [Symbol] the attribute to be validated (cpf)
  # @param value [String] the value of the record's cpf
  def validate_each(record, attribute, value)
    unless validate_cpf(value) 
      record.errors[attribute] << ("#{value} is not a valid CPF")
    end
  end

  # @return [boolean] true if cpf is valid
  # @param cpf [String] the cpf to be validated
  def validate_cpf(cpf)

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
  def check(aux, arr)
    sum = 0
    aux.downto(2).to_a.zip(arr.each) { |i, j| sum += j * i }
    return (((sum * 10) % 11) % 10 == arr[aux - 12])
  end
end
