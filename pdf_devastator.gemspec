# encoding: utf-8
require File.join(File.dirname(__FILE__), 'lib/pdf_devastator/version')

Gem::Specification.new do |s|
  s.name        = 'pdf_devastator'
  s.version     = PDFDevastator::VERSION
  s.platform    = 'java'
  s.authors     = ['Patrik Ragnarsson']
  s.email       = 'patrik@starkast.net'
  s.homepage    = 'https://github.com/dentarg/pdf_devastator'
  s.summary     = 'Fill out PDF files containing XFA forms'
  s.description = <<-EOF
    Fill out PDF files containing Adobe XML Forms Architecture (XFA) forms
    using XML templates.
  EOF

  s.add_dependency 'nokogiri'

  s.files         = Dir['{lib}/**/*.rb']
  s.require_paths = ['lib']
end
