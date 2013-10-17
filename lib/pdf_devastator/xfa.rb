# encoding: utf-8
require 'nokogiri'
require 'java'
require 'pdf_devastator/form'

require File.join(File.dirname(__FILE__), '../../vendor/iText-4.2.0')

java_import "com.lowagie.text.pdf.AcroFields"
java_import "com.lowagie.text.pdf.PdfArray"
java_import "com.lowagie.text.pdf.PdfDictionary"
java_import "com.lowagie.text.pdf.PdfName"
java_import "com.lowagie.text.pdf.PdfObject"
java_import "com.lowagie.text.pdf.PdfReader"
java_import "com.lowagie.text.pdf.PdfStamper"
java_import "com.lowagie.text.pdf.PdfStream"
java_import "com.lowagie.text.pdf.PdfWriter"
java_import "com.lowagie.text.pdf.XfaForm"
java_import "com.lowagie.text.pdf.XfdfReader"

module PDFDevastator
  class Xfa
    XFA_DATASET_XML = "<xfa:datasets xmlns:xfa=\"http://www.xfa.org/schema/xfa-data/1.0/\"><xfa:data xfa:dataNode=\"dataGroup\"/></xfa:datasets>"

    attr_reader :doc

    def initialize(in_file, out_file = nil)
      if out_file
        @out_stream = java.io.FileOutputStream.new(out_file)
      else
        @out_stream = java.io.ByteArrayOutputStream.new
      end
      @reader = PdfReader.new(in_file)
      @stamper = PdfStamper.new(@reader, @out_stream)
      afields = @stamper.getAcroFields
      @xfa = afields.getXfa
      # Double-load to avoid a strange error with Nokogiri and Trinidad
      @doc = Nokogiri::XML(Nokogiri::XML::Document.wrap(@xfa.getDomDocument).to_xml)
    end

    def forms
      forms = @doc.xpath("//*[local-name()='subform']")
      forms.map { |form| PDFDevastator::Form.new(form) }
    end

    def form(name)
      forms.select { |f| f.name.eql? name }.first
    end

    def fill_and_save(xml_string)
      xml = Nokogiri::XML(xml_string)
      data_node = datasets().children.first
      data_node.add_child(xml.root)

      @xfa.setDomDocument(@doc.to_java)
      @xfa.setChanged(true)
      @stamper.close
    end

    def stamped_pdf
      String.from_java_bytes(@out_stream.toByteArray)
    end

    private

    def datasets
      datasets = @doc.xpath('//xfa:datasets', 'xfa' => 'http://www.xfa.org/schema/xfa-data/1.0/')
      if datasets.empty?
        create_dataset_with_data_node
      else
        datasets
      end
    end

    def create_dataset_with_data_node
      new_dataset = Nokogiri::XML(XFA_DATASET_XML)
      result = new_dataset.root
      @doc.root.add_child(new_dataset.root)

      @doc.xpath('//xfa:datasets', 'xfa' => 'http://www.xfa.org/schema/xfa-data/1.0/')
    end
  end
end
