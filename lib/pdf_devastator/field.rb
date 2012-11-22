# encoding: utf-8
require 'nokogiri'

module PDFDevastator
  class Field
    attr_reader :name, :ui, :element

    def initialize(element)
      @element = element
      @ui = self.ui
    end

    def name
      name_attribute = @element.attributes["name"]
      @name ||= name_attribute && name_attribute.value
    end

    def ui
      ui_node = @element.at_xpath("*[local-name()='ui']").children.first
      @type ||= ui_node && ui_node.name
    end
  end
end
