class CpfValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless validate_cpf(value) 
      record.errors[attribute] << ("#{value} is not a valid CPF.")
    end
  end

  # @return [boolean] true if cpf is valid
  def validate_cpf(cpf)
    arr = cpf.to_s.chars.map(&:to_i)
    if arr.count(arr[0]) == arr.size
      return false
    end
    return (check(10, arr) and check(11, arr))
  end

private

  # @return [boolean] true if last two digits are valid
  def check(aux, arr)
    sum = 0
    aux.downto(2).to_a.zip(arr.each) { |i, j| sum += j * i }
    return ((sum * 10) % 11 == arr[aux - 12])
  end
end
