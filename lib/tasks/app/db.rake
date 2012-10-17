namespace :app do
  require 'open3'

########## DB

  namespace :db do
    
    ########## EXPORT WITH DATA

    desc "export application settings and data to json"
    task :export_with_data  => :environment do

      #####################################################
      puts "Exporting people..."
      people = Person.all.as_json(:except => [:delta, :created_at, :updated_at],
                                  :include => {:user => {:except => :person_id,
                                                         :methods => :favorite_ids }})
      
      #####################################################
      puts "Exporting groups..."
      
        class Group
          def person_ids
            users.collect(&:person_id)
          end
        end
        
      groups = Group.all.as_json(:methods => [:type, :person_ids])

      #####################################################
      puts "Exporting media_sets..."
      
        class MediaSet
          def individual_context_ids
            []
          end
        end

      h1 = h2 = {:include => {:meta_data => {:except => [:id, :media_resource_id, :created_at, :updated_at],
                                             :methods => :value },
                              :permissions => {:methods => :actions,
                                               :except => [:id, :media_resource_id, :created_at, :updated_at] },
                              :edit_sessions => {:only => [:created_at, :user_id]}
                              }, # :include => :person
                 :except => [:delta]
                }
          
      h1.merge!(:methods => [:individual_context_ids, :child_ids])

      media_sets = MediaSet.all.as_json(h1)

      #####################################################
      puts "Exporting media_featured_set..."
      media_featured_set_id = AppSettings.featured_set_id

      #####################################################
      puts "Exporting media_entries..."
      h2[:include].merge!(:media_file => {:except => [:id, :meta_data, :job_id, :access_hash, :created_at, :updated_at]
                                          #old#, :include => {:previews => {:except => [:id, :media_file_id, :created_at, :updated_at]}}
                                         })
                                         # TODO include :meta_data
      h2.merge!(:methods => :media_set_ids)
      media_entries = MediaEntry.all.as_json(h2)
  
      #####################################################

      export =  {:subjects => {:people => people,
                               :groups => groups},
                 :media_sets => media_sets,
                 :media_featured_set_id => media_featured_set_id,
                 :media_entries => media_entries }.merge(minimal_export)
      
      write_to_file(export)
    end
    
    ########## EXPORT SETTINGS
    
    desc "export application settings to json"
    task :export => :environment do
      export = minimal_export
      write_to_file(export)
    end
    
  end
  
end

########## HELPERS

def minimal_export
    #####################################################
    puts "Exporting meta_terms..."
    meta_terms = MetaTerm.all.as_json

    #####################################################
    puts "Exporting meta_keys..."
    meta_keys = MetaKey.all.as_json(:methods => :meta_term_ids)

    #####################################################
    puts "Exporting meta_contexts..."
    meta_contexts = MetaContext.all.as_json(:include => {:meta_key_definitions => {:except => [:id, :created_at, :updated_at]}})

    #####################################################
    puts "Exporting copyrights..."
    copyrights = Copyright.all.as_json(:except => [:lft, :rgt])

    #####################################################
    puts "Exporting usage_terms..."
    usage_terms = UsageTerm.all.as_json(:except => :id)

    #####################################################

    # TODO
    #3 wiki_pages + wiki_page_versions

    { :meta_terms => meta_terms,
      :meta_keys => meta_keys,
      :meta_contexts => meta_contexts,
      :copyrights => copyrights,
      :usage_terms => usage_terms }
end

def write_to_file(export)
  file_path = "#{Rails.root}/db/madek_0.3.9.json" 
  File.open(file_path, 'w') do |f|
    f << export.to_json # << "\n"
  end
end


