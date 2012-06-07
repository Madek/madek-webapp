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
      , wiki_pages: :WikiPage \
      , wiki_page_versions: :WikiPageVersion \
      , keywords: :Keyword \
      , full_texts: :FullText \
      , copyrights: :Copyright \
      , meta_terms: :MetaTerm \
      , meta_context_groups: :MetaContextGroup \
      , meta_contexts: :MetaContext \
      , meta_keys: :MetaKey \
      , meta_key_definitions: :MetaKeyDefinition \
      , meta_data: :MetaDatum \
      , meta_keys_meta_terms: :MetaKeyMetaTerm \
      , permission_presets: :PermissionPreset \
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
      , settings: :Setting \
    }


    def self.define_models

      Relations.merge(UndefinedModels).each do |table_name, model_name|
          klass = Class.new ActiveRecord::Base do 
            self.table_name = table_name
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
                #{model}.all.each do|instance|
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


    class NewMadekXmlDoc < ::Nokogiri::XML::SAX::Document
      def initialize
        @stack= []
        Copyright.send :attr_accessor, :lft
        Copyright.send :attr_accessor, :rgt
      end

      def skip_all_callbacks(klass)
        puts ">>>>> skip_all_callbacks for #{klass}"
        [:validation, :save, :create, :commit].each do |name|
          klass.send("_#{name}_callbacks").each do |_callback|
            # HACK - the oracle_enhanced_adapter write LOBs through an after_save callback (:enhanced_write_lobs)
            if (_callback.filter != :enhanced_write_lobs)
              klass.skip_callback(name, _callback.kind, _callback.filter) end
          end
        end
      end


      def get_attr attrs, name
        if arr = attrs.find{|x| x[0]== (name.to_s)}
          arr[1]
        else
          nil
        end
      end

      def get_type attrs
        if type = get_attr(attrs, :type)
          type 
        else
          :unknown
        end
      end

      def new_model  model_name
        model = Module.const_get model_name.gsub(/-/,"_").camelize
        skip_all_callbacks model
        model.new
      end

      def save_model obj
        #puts "\n>>>>>>>>> saving #{obj.class} "
        obj.save!(validate: false)
        #puts "<<<<<<<<<< saved #{obj.class} #{obj.id}"
      end



      def start_element name, attrs = []
        #puts "\n=== START_ELEMENT ==="
        type= get_type attrs
        obj = 
          if @stack.size == 3
            new_model name
          elsif @stack.size >= 4
            case type
            when :array
              []
            end
          end
        @stack.push name: name.gsub(/-/,"_"), type: type, attrs: attrs, chars: "" , depth: @stack.size, obj: obj
        #puts @stack
      end

      def characters s
        current = @stack.pop
        current[:chars]= current[:chars] + s
        @stack.push current
      end

      def end_element name
        puts "\n=== END_ELEMENT ==="
        puts @stack
        current = @stack.pop
        parent = @stack.pop


        # step1 get current value
        value= 
          if get_attr(current[:attrs], :nil) and get_attr(current[:attrs], :nil) == "true"
            nil
          else
            case current[:type]
            when "integer"
              current[:chars].to_i
            else
              current[:chars]
            end
          end

        #binding.pry if current[:name] == "description_id"

        # step2 integrate the last object in its parent object
        if parent
          if pobj = parent[:obj]
            if pobj.is_a? Array
              pobj << value
            elsif pobj.is_a? ActiveRecord::Base
              pobj.send "#{current[:name]}=", value
            end
          end
          @stack.push parent
        end

        # step3 save the current object if it is a model
        if cobj = current[:obj] 
          save_model cobj if cobj.is_a? ActiveRecord::Base
        end

      end

    end







    ### IMPORT

    class MadekXmlDoc < ::Nokogiri::XML::SAX::Document

      SerializedFields = []


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
              klass.skip_callback(name, _callback.kind, _callback.filter) end
          end
        end
      end

      def new_model table_name, model_name
        model = Module.const_get model_name.gsub(/-/,"_").camelize
        skip_all_callbacks model
        puts "\n\n\n################################################"
        puts "setting current_model to new instance of #{model}"
        @current_model = model.new
      end

      def new_relation name
        @current_relation = {}
      end

      def set_property name, value
        puts "set_property #{name} (size #{value.size}) to #{value}"
        #somehow this doesn't work
        value = YAML::load(value) if SerializedFields.include? name.to_sym
        puts "value: #{value}"
        @current_model.send "#{name}=", value
      end

      def save_current_model
        puts "saving #{@current_model.class} "
        @current_model.save!(validate: false)
        puts "saved #{@current_model.class} #{@current_model.id}"
        @current_model=nil
      end

      def insert_relation
        names =  " ( #{@current_relation.keys.join(", ")} )".gsub /-/,"_"
        values = " ( #{@current_relation.values.join(", ")} )"
        sql = " INSERT INTO #{@current_table} #{names} VALUES #{values}; " 
        puts sql
        SQLHelper.execute_sql sql
      end

      def start_element name, attrs = []
        #puts "starting: #{name}"
        @state_stack.push name
        if @state_stack.size == 3
          @current_table = name.gsub /-/, "_"
        elsif @state_stack.size == 4 and @state_stack[1] == "data"
          _,_,table_name,model_name = @state_stack 
          #puts "new model element STATE #{@state_stack}"
          new_model table_name, model_name
        elsif @state_stack.size == 5 and @state_stack[1] == "data"
          puts "> property #{name} #{attrs}" 
          @value = ""
        elsif @state_stack.size == 4 and @state_stack[1] == "relations"
          new_relation name
        elsif @state_stack.size == 5 and @state_stack[1] == "relations"
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
        elsif  @state_stack.size == 4 and @state_stack[1] == "relations"
          puts "CREATE RELATION #{@current_table}: #{@current_relation}"
          insert_relation
        elsif  @state_stack.size == 5 and @state_stack[1] == "relations"
          @current_relation[name] = @value
        end
        @state_stack.pop
      end

    end



    def self.db_import_from_xml source 
      ::DevelopmentHelpers::Xml.define_models
      ActiveRecord::Base.transaction do
        parser = Nokogiri::XML::SAX::Parser.new(NewMadekXmlDoc.new)
        parser.parse(source)
      end
    end

  end
end
