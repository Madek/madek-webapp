module DevelopmentHelpers
  module Xml

    # adhoc models for joint tables; good for now, check if doesn't create problems 
    class ::SchemaMigration < ActiveRecord::Base
    end
    class ::MediaEntriesMediaSet < ActiveRecord::Base
    end
    class ::Favorite < ActiveRecord::Base
    end
    class ::GroupsUser < ActiveRecord::Base
    end
    class ::MediaSetsMetaContext < ActiveRecord::Base
    end
    class ::Setting < ActiveRecord::Base
    end
    class ::MetaKeysMetaTerm < ActiveRecord::Base
    end


    # get superlist of the following with 
    #   ActiveRecord::Base.connection.tables.each { |t| puts ", #{t}: :#{t.to_s.camelize.singularize} \\" }
    # now, filter and oder appropriately

    TablesModels =  { \
        people: :Person \
      , groups: :Group \
      , users: :User \
      , media_resources: :MediaResource \
      , media_set_arcs: :MediaSetArc \
      , userpermissions: :Userpermission \
      , grouppermissions: :Grouppermission \
      , media_files: :MediaFile \
      , previews: :Preview \
      , usage_terms: :UsageTerm \
      , edit_sessions: :EditSession \
      , upload_sessions: :UploadSession \
      , wiki_pages: :WikiPage \
      , wiki_page_versions: :WikiPageVersion \
      , type_vocabularies: :TypeVocabulary \
      , keywords: :Keyword \
      , full_texts: :FullText \
      , copyrights: :Copyright \
      , meta_terms: :MetaTerm \
      , meta_key_definitions: :MetaKeyDefinition \
      , meta_contexts: :MetaContext \
      , meta_keys: :MetaKey \
      , meta_data: :MetaDatum \
      , meta_keys_meta_terms: :MetaKeysMetaTerm \
    }

    # this contains all the join tables
    Relations=  { \
        favorites: :Favorite \
      , groups_users: :GroupsUser \
      , media_entries_media_sets: :MediaEntriesMediaSet \
      , media_sets_meta_contexts: :MediaSetsMetaContext \
    }



    ### EXPORT

    def self.db_export_to_xml target = $stdout
      require 'builder' unless defined? ::Builder

      xml = Builder::XmlMarkup.new(target: target, indent: 2)
      xml.instruct!

      xml.madek do

        xml.meta do |meta|
            meta << SchemaMigration.order("VERSION DESC").limit(1).to_xml(skip_instruct: true).gsub(/^/, '      ')
        end

        xml.data do 
          TablesModels.each do |table_name,model|
            eval " 
              xml.#{table_name} do |table|
                #{model}.all.each do |instance|
                  table << instance.to_xml(skip_instruct: true).gsub(/^/, '      ')
                end
              end
            "
          end
        end

        xml.relations do
          Relations.each do |table_name,model|
            eval " 
              xml.#{table_name} do |table|
                #{model}.all.each do |instance|
                  table << instance.to_xml(skip_instruct: true).gsub(/^/, '      ')
                end
              end
            "
          end
        end
      end

    end


    ### IMPORT

    class MadekXmlDoc < ::Nokogiri::XML::SAX::Document

      def initialize
        @state_stack = []
        @value = ""
        @current_model = nil
      end

      def new_model table_name, model_name
        puts "setting current_model to new instance of #{table_name.singularize.camelize}"
      end

      def start_element name, attrs = []
        #puts "starting: #{name}"
        @state_stack.push name
        if @state_stack.size == 4 and @state_stack[1] == "data"
          _,_,table_name,model_name = @state_stack 
          #puts "new model element STATE #{@state_stack}"
          new_model table_name, model_name
        elsif @state_stack.size == 5 and @state_stack[1] == "data"
          puts "> property #{name} #{attrs}" 
          @value = ""
        end

      end

      def characters s
        @value += s
      end

      def end_element name
        if @state_stack.size == 4 and @state_stack[1] == "data"
          puts; puts
        elsif @state_stack.size == 5 and @state_stack[1] == "data"
          _,_,table_name,model_name = @state_stack 
          puts "end of proverty value STATE #{@state_stack}"
          puts "---- end of element ----"
          puts @value
          puts "---- end of element ----"
          puts 
        end
        @state_stack.pop
      end

    end



    def self.db_import_from_xml source 
      parser = Nokogiri::XML::SAX::Parser.new(MadekXmlDoc.new)
      parser.parse(source)
    end

  end
end
