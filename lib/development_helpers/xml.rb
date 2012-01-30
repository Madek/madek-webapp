module DevelopmentHelpers
  module Xml

    class SchemaMigration < ActiveRecord::Base
    end

    class MediaEntriesMediaSet < ActiveRecord::Base
    end

    class Favorite < ActiveRecord::Base
    end

    class GroupsUser < ActiveRecord::Base
    end

    class MediaSetsMetaContext < ActiveRecord::Base
    end

    class Setting < ActiveRecord::Base
    end


    # get superlist of the following with 
    #   ActiveRecord::Base.connection.tables.each { |t| puts ", #{t}: :#{t.to_s.camelize.singularize} \\" }
    # now, filter and oder appropriately

    TablesModels =  { \
        schema_migrations: :SchemaMigration \
      , type_vocabularies: :TypeVocabulary \
      , media_entries_media_sets: :MediaEntriesMediaSet \
      , previews: :Preview \
      , copyrights: :Copyright \
      , favorites: :Favorite \
      , groups_users: :GroupsUser \
      , users: :User \
      , people: :Person \
      , groups: :Group \
      , upload_sessions: :UploadSession \
      , usage_terms: :UsageTerm \
      , keywords: :Keyword \
      , media_sets_meta_contexts: :MediaSetsMetaContext \
      , edit_sessions: :EditSession \
      , media_files: :MediaFile \
      , wiki_pages: :WikiPage \
      , wiki_page_versions: :WikiPageVersion \
      , permissions: :Permission \
      , settings: :Setting \
      , media_set_arcs: :MediaSetArc \
      , full_texts: :FullText \
      , userpermissions: :Userpermission \
      , media_resources: :MediaResource \
      , grouppermissions: :Grouppermission \
    }

#      , meta_terms: :MetaTerm \
#      , meta_key_definitions: :MetaKeyDefinition \
#      , meta_contexts: :MetaContext \
#      , meta_keys: :MetaKey \
#      , meta_data: :MetaDatum \
#      , meta_keys_meta_terms: :MetaKeysMetaTerm \


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
