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

require 'curb'
require 'nokogiri'

def is_number? string
  true if Float(string) rescue false
end

module Agendador
  module CEP
    class Finder
      Curl::Easy

      def self.get(zipcode)
        return self.get_postmon(zipcode)
        #return self.get_correios(zipcode)
      end

      def self.get_correios(zipcode)
        xml_text= '<?xml version="1.0" encoding="UTF-8"?>' +
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
          'xmlns:cli="http://cliente.bean.master.sigep.bsb.correios.com.br/">' +
          '<soapenv:Header />' +
          '<soapenv:Body>' +
          '<cli:consultaCEP>' +
          "<cep>#{zipcode}</cep>" +
          '</cli:consultaCEP>' +
          '</soapenv:Body>' +
          '</soapenv:Envelope>'

        http = Curl.post("https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente", xml_text)

        doc = Nokogiri::XML(http.body_str)
        doc.encoding = 'UTF-8'

        address = Hash.new

        if doc.at_xpath("//faultstring").nil?
          address[:zipcode] = doc.xpath("//cep").text.force_encoding("ISO-8859-1").encode("UTF-8")
          address[:address] =  doc.xpath("//end").text.force_encoding("ISO-8859-1").encode("UTF-8")
          address[:neighborhood] = doc.xpath("//bairro").text.force_encoding("ISO-8859-1").encode("UTF-8")
          address[:city] =  doc.xpath("//cidade").text.force_encoding("ISO-8859-1").encode("UTF-8")
          address[:state] = doc.xpath("//uf").text.force_encoding("ISO-8859-1").encode("UTF-8")
          address[:complement] = doc.xpath("//complemento").text.force_encoding("ISO-8859-1").encode("UTF-8")
          address[:complement2] = doc.xpath("//complemento2").text.force_encoding("ISO-8859-1").encode("UTF-8")
        end

        return address
      end

      def self.get_postmon(zipcode)
        # uri = URI("http://api.postmon.com.br/v1/cep/#{zipcode}?format=xml")
        uri = URI("http://postmon.c3sl.ufpr.br/v1/cep/#{zipcode}?format=xml")
        doc = Nokogiri::XML(Net::HTTP.get(uri))
        doc.encoding = 'UTF-8'

        address = Hash.new

        if doc.at_xpath("//faultstring").nil?
          address[:zipcode] = doc.xpath("//cep").text
          address[:address] =  doc.xpath("//logradouro").text
          address[:neighborhood] = doc.xpath("//bairro").text
          address[:city] =  doc.xpath("//cidade").text
          address[:state] = doc.xpath("//estado").text
          address[:number] = nil

          # Get the last three digits from the zipcode
          zipcode_suffix = address[:zipcode].split(//).last(3).join

          # Check specific cases of CEP codes that may have a number included
          # in its address field, the following address shows more details:
          # https://www.correios.com.br/precisa-de-ajuda/
          # o-que-e-cep-e-por-que-usa-lo/estrutura-do-cep
          if zipcode_suffix.to_i >= 900 and zipcode_suffix.to_i <= 969
            # Split the address by comma
            address_splitted = address[:address].split(',')

            # If there is more elements in the array, so there's a comma in the
            # address (probably separating address and number)
            if address_splitted.length > 1
              # Get possible number from address
              number = address_splitted.last.strip

              # Verify if number is numeric, if it is, change the address to
              # the part of address without the number and set the number
              # field in the address
              if is_number?(number)
                address[:address] = address_splitted[0].strip
                address[:number] = number.to_i
              end
            end
          end
        end

        return address
      end
    end
  end
end
