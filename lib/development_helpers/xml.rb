module DevelopmentHelpers
  module Xml


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

    UndefinedModels= { \
        schema_migrations: :SchemaMigration \
      , meta_keys_meta_terms: :MetaKeysMetaTerm \
    }


    def self.define_models

      Relations.merge(UndefinedModels).each do |table_name, model_name|
          klass = Class.new ActiveRecord::Base do 
            set_table_name table_name
          end
          Object.const_set model_name, klass
      end

    end



    ### EXPORT

    def self.db_export_to_xml target = $stdout
      require 'builder' unless defined? ::Builder
      ::DevelopmentHelpers::Xml.define_models


      xml = Builder::XmlMarkup.new(target: target, indent: 2)
      xml.instruct!

      xml.madek do

        xml.meta do |meta|
            meta << SchemaMigration.order("VERSION DESC").limit(1).to_xml(skip_instruct: true)
        end

        xml.data do 
          TablesModels.each do |table_name,model|
            eval " 
              xml.#{table_name} do |table|
                #{model}.all.each do |instance|
                  table << instance.to_xml(skip_instruct: true)
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
                  table << instance.to_xml(skip_instruct: true)
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

        Copyright.send :attr_accessor, :lft
        Copyright.send :attr_accessor, :rgt

      end

      def skip_all_callbacks(klass)
        [:validation, :save, :create, :commit].each do |name|
          klass.send("_#{name}_callbacks").each do |_callback|
            # HACK - the oracle_enhanced_adapter write LOBs through an after_save callback (:enhanced_write_lobs)
            if (_callback.filter != :enhanced_write_lobs)
              klass.skip_callback(name, _callback.kind, _callback.filter)
            end
          end
        end
      end

      def new_model table_name, model_name
        model = Module.const_get table_name.singularize.camelize
        skip_all_callbacks model
        puts "\n\n\n################################################"
        puts "setting current_model to new instance of #{model}"
        @current_model = model.new
      end

      def set_property name, value
        puts "set_property #{name} (size #{value.size}) to #{value}"
        @current_model.send "#{name}=", value
      end

      def save_current_model
        puts "saving #{@current_model.class} "
        @current_model.save!(validate: false)
        puts "saved #{@current_model.class} #{@current_model.id}"
        @current_model=nil
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
          save_current_model 
        elsif @state_stack.size == 5 and @state_stack[1] == "data"
          _,_,table_name,model_name,property_name= @state_stack 
          set_property property_name.gsub("-","_"), @value
        end
        @state_stack.pop
      end

    end



    def self.db_import_from_xml source 
      ActiveRecord::Base.transaction do
        parser = Nokogiri::XML::SAX::Parser.new(MadekXmlDoc.new)
        parser.parse(source)
        raise "don't import just yet"
      end
    end

  end
end
