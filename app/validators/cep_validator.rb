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
      record.errors[attribute] << ("#{value} is not a valid cep")
    end
  end

  # Finds address corresponding to cep
  # @param cep [String] cep number
  # @return [Json] json containing address information
  def self.get_address(cep)
    Correios::CEP::AddressFinder.get(cep)
  end

  def self.valid_format?(cep)
    CEP_REGEX.match(cep)
  end
end
