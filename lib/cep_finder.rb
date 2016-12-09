require 'curb'
require 'nokogiri'

module Agendador
  module CEP
    class Finder
      Curl::Easy

      def self.get(zipcode)
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

        address
      end  
    end  
  end  
end
