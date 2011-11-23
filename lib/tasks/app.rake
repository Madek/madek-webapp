def minimal_export
    #####################################################
    puts "Exporting meta_terms..."
    meta_terms = Meta::Term.all.as_json

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


namespace :app do

  desc "import minimal setup data (meta....)"
  task :import_min_setup => :environment do


    # TODO cleanup and remove from admin meta controller
    @buffer = []

    ActiveRecord::Base.transaction do

      ###################################################
      # collect existing meta_data references
      @meta_data = {}
      MetaDatum.all.each do |meta_datum|
        @meta_data[meta_datum.id] = { :meta_key_label => meta_datum.meta_key.label } 

        # OPTIMIZE
        case meta_datum.meta_key.object_type
        when "Meta::Term", "Meta::Date" 
          if meta_datum.value.empty?
            meta_datum.destroy
            next
          end
          if meta_datum.meta_key.object_type == "Meta::Term"
            @meta_data[meta_datum.id][:meta_terms] = Meta::Term.find(meta_datum.value).collect do |term|
              b = {}
              LANGUAGES.each do |lang|
                s = term.send(lang)
                b[lang] = s unless s.blank? 
              end
              b
            end
          end
        end

      end

      MetaDatum.update_all("meta_key_id = (meta_key_id * -1)")

      ###################################################
      # core meta import
      meta = YAML.load(File.read("#{Rails.root}/features/data/minimal_meta.yml"))

      #binding.pry

      if meta[:meta_terms] and meta[:meta_keys] and meta[:meta_contexts] and meta[:meta_key_definitions]   

        [MetaKey, MetaContext, MetaKeyDefinition, Meta::Term, UsageTerm].each {|a| a.destroy_all }

        meta[:meta_terms].each do |term|
          k = Meta::Term.new(term)
          k.id = term["id"]
          k.save
          #            @buffer << k.inspect
        end

        meta[:meta_keys].each do |meta_key|
          meta_terms = meta_key.delete("meta_terms")
          k = MetaKey.new(meta_key)
          k.id = meta_key["id"]
          k.save
          k.meta_terms << Meta::Term.find(meta_terms) if meta_terms
          #            @buffer << k.inspect
        end

        meta[:meta_contexts].each do |meta_context|
          k = MetaContext.new(meta_context)
          k.id = meta_context["id"]
          k.save
          #            @buffer << k.inspect
        end

        meta[:meta_key_definitions].each do |meta_key_definition|
          k = MetaKeyDefinition.new(meta_key_definition)
          k.id = meta_key_definition["id"]
          k.save
          #            @buffer << k.inspect
        end

        k = UsageTerm.new(meta[:usage_terms])
        k.id = meta[:usage_terms]["id"]
        k.save
      end

      ###################################################
      # re-reference existing meta_data

      #        @buffer << @meta_data.inspect
      #        @buffer << "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

      @meta_keys = {}
      MetaDatum.where("meta_key_id < 0").each do |meta_datum|
        k = @meta_keys[@meta_data[meta_datum.id][:meta_key_label]] ||= MetaKey.find_by_label(@meta_data[meta_datum.id][:meta_key_label])
        meta_datum.meta_key = k

        if k.object_type == "Meta::Term"
          meta_datum.value = if @meta_data[meta_datum.id][:meta_terms]
                               @meta_data[meta_datum.id][:meta_terms].map {|h| k.meta_terms.where(h).first.try(:id) }
                             else
                               # OPTIMIZE 2210 search as OR condition
                               conditions = {}
                               LANGUAGES.each do |lang|
                                 conditions[lang] = meta_datum.value   
                               end
                               k.meta_terms.where(conditions).first
                             end.compact
        end

        unless meta_datum.save
          @buffer << meta_datum.inspect
          @buffer << meta_datum.errors.full_messages
          @buffer << "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
          break
        end
      end

      negatives = MetaDatum.where("meta_key_id < 0").count
      if negatives > 0
        @buffer << "--- ERROR: %d meta_data aren't correctly restored ---" % negatives
        ActiveRecord::Base.connection.rollback_db_transaction
        @buffer << "--- The import has been aborted with rollback ---"
      else
        # Sphinx is not needed anymore
        #@buffer << `rake ts:reindex`
        @buffer << "--- Import completed successfully ---"
      end

    end
  end



  desc "Build Railroad diagrams (requires peterhoeg-railroad 0.5.8 gem)"
  task :railroad do
    `railroad -iv -o doc/diagrams/railroad/controllers.dot -C`
    # `railroad -iv -o doc/diagrams/railroad/models.dot -M`
    `bundle viz -V -f doc/diagrams/gem_graph.png`
  end

  namespace :db do
    desc "export application settings and data to json"
    task :export_with_data  => :environment do

      #####################################################
      puts "Exporting people..."
      people = Person.all.as_json(:except => [:delta, :created_at, :updated_at],
                                  :include => {:user => {:except => :person_id,
                                                         :methods => :favorite_ids,
                                                         :include => {:upload_sessions => {:except => [:user_id, :updated_at]}} }})
      
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
      
        class Media::Set
          def individual_context_ids
            []
          end
        end

      h1 = h2 = {:include => {:meta_data => {:except => [:id, :resource_type, :resource_id, :created_at, :updated_at],
                                             :methods => :deserialized_value },
                              :permissions => {:methods => :actions,
                                               :except => [:id, :resource_type, :resource_id, :created_at, :updated_at] },
                              :edit_sessions => {:only => [:created_at, :user_id]}
                              }, # :include => :person
                 :except => [:delta]
                }
          
      h1.merge!(:methods => [:individual_context_ids, :child_ids])

      media_sets = Media::Set.all.as_json(h1)

      #####################################################
      puts "Exporting media_featured_set..."
      media_featured_set_id = Media::FeaturedSet.first.try(:id)

      #####################################################
      puts "Exporting media_entries..."
      h2[:include].merge!(:media_file => {:except => [:id, :meta_data, :job_id, :access_hash, :created_at, :updated_at]
                                          #old#, :include => {:previews => {:except => [:id, :media_file_id, :created_at, :updated_at]}}
                                         })
                                         # TODO include :meta_data
      h2.merge!(:methods => :media_set_ids)
      media_entries = MediaEntry.all.as_json(h2)
  
      #####################################################
      puts "Exporting snapshots..."
      snapshots = Snapshot.all.as_json(h2)

      #####################################################

      export =  {:subjects => {:people => people,
                               :groups => groups},
                 :media_sets => media_sets,
                 :media_featured_set_id => media_featured_set_id,
                 :media_entries => media_entries,
                 :snapshots => snapshots }.merge(minimal_export)
      
      write_to_file(export)
    end
    
    desc "export application settings to json"
    task :export => :environment do
      export = minimal_export
      write_to_file(export)
    end
  end
  
end
