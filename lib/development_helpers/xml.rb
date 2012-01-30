module DevelopmentHelpers
  module Xml


    # get superlist of the following with 
    #   ActiveRecord::Base.connection.tables.each { |t| puts "#{t}: #{t.to_s.camelize.singularize}," }
    # now, filter and oder appropriately

    TablesModels = { \
      users: :User,
      people: :Person,
      groups: :Group 
    }

    def self.to_xml
      require 'builder' unless defined? ::Builder

      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!

      xml.data do 
        TablesModels.each do |table_name,model|
          eval " 
          xml.#{table_name} do |table|
            #{model}.all.each do |instance|
              table << instance.to_xml(skip_instruct: true).gsub(/^/, '    ')
            end
          end
          "
        end
      end

    end
  end
end
