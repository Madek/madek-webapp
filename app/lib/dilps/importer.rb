module ::Dilps::Importer

  # Dilps::Importer.import Dilps::SuperItem.find(8,3283), User.last

  DILPS_FILE_STORE = 
    if not (store = ENV['DILPS_FILE_STORE']).blank? 
      Pathname.new store
    else
      Rails.root.join "tmp", "dilps_images"
    end

  SUSANNES_IMPORT_GROPUS = %w(
              zhdk/schumacher
              local/juri 
              local/kumar 
              local/schwarze 
              local/skarda 
              local/ullmann 
              local/wieland 
              local/zingg 
              local/zuni 
              local/baumberger 
              local/geiger 
              local/riederer 
              local/vass 
           )

  class << self

    def import_susannes_stuff user
      # TODO insert other users
      Dilps::SuperItem.by_user(SUSANNES_IMPORT_GROPUS).each do |super_item|
        wrap_exception super_item do
          import super_item, user
        end
      end
    end

    def import_distinct_items super_items, user
      imported_items  = Set.new

      items.each do |super_item|
        unless imported_items.include? [super_item.collection_id,super_item.item_id]
          import super_item, user
          imported_items << [super_item.collection_id,super_item.item_id] rescue Exception
        end
      end
    end

    def import super_item, user

      absulute_image_path = DILPS_FILE_STORE.join super_item.resource_path

      original_file_path = if File.exists? absulute_image_path and FileTest.file? absulute_image_path
                             absulute_image_path
                           else
                             prefix = DILPS_FILE_STORE.join  ("." + super_item.collection.storage_dir), 
                               'master' + File::SEPARATOR +  (super_item.collection_id.to_s + "_" + super_item.item_id.to_s)
                              Dir.glob(prefix.to_s + "*").first
                           end

      temp_file = Rails.root.join("tmp", File.basename(original_file_path) ).to_s
      FileUtils.cp(original_file_path, temp_file)


      mei = MediaEntryIncomplete.create! user: user, uploaded_data:  \
        ActionDispatch::Http::UploadedFile.new( \
                                               :type=> Rack::Mime.mime_type(File.extname(temp_file)),
                                               :tempfile=> File.new(temp_file, "r"),
                                               :filename=> File.basename(temp_file))

      mei.set_as_complete

      media_entry = MediaEntry.find mei.id


      string_mapings = { 
        addition: 'remark',
        country: 'portrayed object country', 
        dating: 'portrayed object dates',
        dilps_format: 'portrayed object materials',
        institution: 'participating institution',
        location: 'portrayed object city',
        source: 'source',
        title: 'title'}

      string_mapings.each do |attr_name, meta_key|
        unless super_item.send(attr_name).blank? 
          create_or_append_to_meta_datum media_entry, meta_key, super_item.send(attr_name)
        end
      end

      #source
      wrap_exception super_item do
        create_or_append_to_meta_datum media_entry, 'source', super_item.source unless super_item.source.blank? 
      end

      #keyword
      wrap_exception super_item do
        if not (word =  super_item.keyword).blank? 
          meta_term = MetaTerm.find_or_create_by_de_ch word
          add_to_keywords media_entry, 'keywords', meta_term, user
        end
      end

      # authors
      wrap_exception super_item do
        [super_item.name1, super_item.name2].reject{|name| name.blank? }.each do |last_name| 
          add_to_people media_entry, 'author', last_name
        end
      end

      # Keywords
      wrap_exception super_item do
        super_item.keyword_groups.map(&:l3_name).map(&:strip).uniq.each do |word| 
          meta_term = MetaTerm.find_or_create_by_de_ch word
          add_to_keywords media_entry, 'keywords', meta_term, user
        end
      end


      # Sets 
      wrap_exception super_item do
        (super_item.user_groups.map(&:l3_name).map(&:strip) << 'Dilps Import').uniq.each do |set_title|
          set = user.media_sets.find_by_title(set_title) || create_set_by_title(user,set_title) 
          set.child_media_resources << media_entry rescue Exception
        end
      end

      super_item.extended_data.each do |extended_datum|
        wrap_exception super_item do

          case extended_datum.name

          when 'author::string'
            add_to_people media_entry, "creator", extended_datum.string

          when 'date::string' 
            create_or_append_to_meta_datum media_entry, 'portrayed object dates', extended_datum.string

          when 'time::text' 
            create_or_append_to_meta_datum media_entry, 'date created', extended_datum.string

          when 'addition::string', 'comment::string'
            create_or_append_to_meta_datum media_entry, 'remark',  extended_datum.string

          when 'material::string'
            add_to_meta_terms media_entry, 'portrayed object materials', extended_datum.string

          when 'material::text'
            add_to_meta_terms media_entry, 'portrayed object materials', extended_datum.text

          when 'latitude::text','technique::string', 'table::string'
            create_or_append_to_meta_datum media_entry, 'remark',  extended_datum.text

          when 'orderedby::text' 
            create_or_append_to_meta_datum media_entry, 'patron',  extended_datum.text

          when 'rights::string' 
            create_or_append_to_meta_datum media_entry, 'copyright notice', extended_datum.string


          when 'description::string' 
            create_or_append_to_meta_datum media_entry, 'description', extended_datum.string
          when 'description::text' 
            create_or_append_to_meta_datum media_entry, 'description', extended_datum.text


          when 'figure::string', 'source::string', 'page::string', 'plate::string'
            create_or_append_to_meta_datum media_entry, 'source', extended_datum.string

          else

          end

        end

      end

      media_entry.reindex

    end

    def create_or_append_to_meta_datum media_resource, meta_key_id, str 
      if md = media_resource.meta_data.where(meta_key_id: meta_key_id).first 
        md.update_attributes! string: (md.string + "; " + str)
      else
          media_resource.meta_data.create!(meta_key_id: meta_key_id) \
            .update_attributes! string: str
      end
    end

    def add_to_meta_terms media_resource, meta_key_id, str
      meta_term = MetaTerm.find_or_create_by_de_ch str
      meta_datum = (media_resource.meta_data.where(meta_key_id: meta_key_id).first || 
                    media_resource.meta_data.create!(meta_key_id: meta_key_id))
      meta_datum.meta_terms << meta_term  rescue Exception
    end

    def add_to_keywords media_resource, meta_key_id, meta_term, user
      meta_datum = (media_resource.meta_data.where(meta_key_id: meta_key_id).first || 
                    media_resource.meta_data.create!(meta_key_id: meta_key_id))
      Keyword.create! meta_term: meta_term, user: user, meta_datum: meta_datum
    end


    def add_to_people media_resource, meta_key_id, last_name
      meta_datum = (media_resource.meta_data.where(meta_key_id: meta_key_id).first || 
                    MetaDatum.create!(meta_key_id: meta_key_id, media_resource: media_resource) )


      meta_datum.people << (Person.where(last_name: last_name, first_name: nil).first || 
                            Person.create!(last_name: last_name)) rescue Exception
    end

    def create_set_by_title user, title
      set = MediaSet.create!(user: user)
      set.meta_data.create!(meta_key_id: 'title', string: title)
      set 
    end

    def wrap_exception super_item
      begin 
        yield
      rescue Exception => e
        relevant_trance = e.backtrace.select{|line| line =~ /\/madek\//}
        open Rails.root.join("log", "dilps_import.log"), 'a' do |import_log_file|
          import_log_file \
            << "super_item (#{super_item.collection_id},#{super_item.item_id}) \n" \
            << e.message.to_s + "\n" << relevant_trance.join("\n") << "\n\n"
        end
      end
    end

  end
end
