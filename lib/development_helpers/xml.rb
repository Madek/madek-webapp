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
      , groups_users: :GroupsUser \
      , media_resources: :MediaResource \
      , favorites: :Favorite \
      , media_set_arcs: :MediaSetArc \
      , media_sets_meta_contexts: :MediaSetsMetaContext \
      , userpermissions: :Userpermission \
      , grouppermissions: :Grouppermission \
      , media_entries_media_sets: :MediaEntriesMediaSet \
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


    def self.db_dump_to_xml target = $stdout
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
      end

    end
  end
end
