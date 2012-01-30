module DevelopmentHelpers
  module Xml

    def self.to_xml
      require 'builder' unless defined? ::Builder

      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!

      xml.people do |people|
        Person.all.each do |person|
          people << person.to_xml(skip_instruct: true)
        end
      end

    end

  end
end
