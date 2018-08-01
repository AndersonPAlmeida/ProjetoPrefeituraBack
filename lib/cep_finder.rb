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
        end

        return address
      end
    end
  end
end
