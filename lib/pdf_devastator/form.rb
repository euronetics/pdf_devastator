# encoding: utf-8
require 'nokogiri'
require 'pdf_devastator/field'

module PDFDevastator
  class Form
    attr_reader :name, :fields

    def initialize(element)
      @element = element
    end

    def name
      name_attribute = @element.attributes["name"]
      @name ||= name_attribute && name_attribute.value
    end

    def fields
      fields = @element.children.xpath("*[local-name()='field']")
      @fields ||= fields.map { |field| PDFDevastator::Field.new(field) }
    end
  end
end
