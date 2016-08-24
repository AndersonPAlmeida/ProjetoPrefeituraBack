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
      record.errors[attribute] << ("#{value} is not a valid email")
    end
  end
end
