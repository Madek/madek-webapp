require 'builder'

# Empty XMP sidecar with the given properties, to be filled in by users
class XmpTemplate
  RDF_URI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'.freeze

  def initialize(xmp_properties)
    @xmp_properties = xmp_properties.to_a
  end

  def to_xml
    xml = Builder::XmlMarkup.new(indent: 1)
    xml.instruct!
    xml.tag!('x:xmpmeta', 'xmlns:x' => 'adobe:ns:meta/') do
      xml.tag!('rdf:RDF', 'xmlns:rdf' => RDF_URI) do
        xml.tag!('rdf:Description', { 'rdf:about' => '' }.merge(namespace_declarations)) do
          @xmp_properties.each { |property| property_element(xml, property) }
        end
      end
    end
    xml.target!
  end

  private

  def namespace_declarations
    @xmp_properties.map(&:xmp_namespace).uniq.to_h do |namespace|
      ["xmlns:#{namespace.prefix}", namespace.uri]
    end
  end

  def property_element(xml, property)
    xml.comment!(property.label) if property.label
    name = property.qualified_name
    case property.value_type
    when 'Lang Alt'
      xml.tag!(name) { xml.tag!('rdf:Alt') { xml.tag!('rdf:li', '', 'xml:lang' => 'x-default') } }
    when 'bag Text'
      xml.tag!(name) { xml.tag!('rdf:Bag') { xml.tag!('rdf:li', '') } }
    when 'seq Text'
      xml.tag!(name) { xml.tag!('rdf:Seq') { xml.tag!('rdf:li', '') } }
    else
      xml.tag!(name, '')
    end
  end
end
