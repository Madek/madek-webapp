module Json
  module MediaResourceHelper

    def hash_for_media_resource(media_resource, with = nil)
      h = {
        id: media_resource.id,
        type: media_resource.type.underscore
      }
      
      if with ||= nil
        [:user_id, :created_at, :updated_at].each do |k|
          h[k] = media_resource.send(k) if with[k]
        end
      
        if with[:image]
          size = with[:image][:size] || :small # TODO :small_125 ??
          h[:image] = case with[:image][:as]
            when "base64"
              media_resource.get_media_file(current_user).try(:thumb_base64, size)
            else # default return is a url to the image
              "/media_resources/%d/image?size=%s" % [media_resource.id, size]
          end            
        end
        
        if with[:meta_data]
          h[:meta_data] = []
          if meta_context_names = with[:meta_data][:meta_context_names]
            meta_context_names.each do |name|
              h[:meta_data] += media_resource.meta_data_for_context(MetaContext.send(name)).map do |md|
                hash_for md, {:label => {:context => name}}
              end
            end
          end
          if meta_key_names = with[:meta_data][:meta_key_names]
            h[:meta_data] += meta_key_names.map do |name|
              md = media_resource.meta_data.get(name)
              hash_for md # NOTE we do not request labels, because are context related
            end
          end
        end
        
        if with[:media_type]
          h[:media_type] = media_resource.media_type
        end
        
        if with[:filename]
          h[:filename] = media_resource.is_a?(MediaSet) ? nil : media_resource.media_file.filename
        end

        if with[:size]
          h[:size] = media_resource.is_a?(MediaSet) ? nil : media_resource.media_file.size
        end

        if with[:flags]
          h[:is_public] = media_resource.is_public?
          h[:is_private] = h[:is_public] ? false : media_resource.is_private?(current_user)
          h[:is_shared] = (not h[:is_public] and not h[:is_private]) # TODO drop and move to frontend
          h[:is_editable] = current_user.authorized?(:edit, media_resource)
          h[:is_manageable] = current_user.authorized?(:manage, media_resource)
          h[:is_favorite] = current_user.favorite_ids.include?(media_resource.id)
        end
        
        if with[:parents]
          pagination = ((with[:parents].is_a? Hash) ? with[:parents][:pagination] : nil) || true
          forwarded_with = (with[:parents].is_a? Hash) ? (with[:parents][:with]||=nil) : nil
          h[:parents] = hash_for_media_resources_with_pagination(media_resource.parents, pagination, forwarded_with)
        end
      
        case media_resource.type
          when "MediaSet"
            if with[:children]
              h[:children] = begin
                type = with[:children].is_a?(Hash) and with[:children][:type] ? with[:children][:type] : nil 
                media_resources = if type == "media_entry"
                  media_resource.media_entries
                elsif type == "media_set"
                  media_resource.child_sets
                else # respond with media_resources children
                  media_resource.children
                end
                pagination = ((with[:children].is_a? Hash) ? with[:children][:pagination] : nil) || true
                forwarded_with = (with[:children].is_a? Hash) ? (with[:children][:with]||=nil) : nil
                hash_for_media_resources_with_pagination(media_resources, pagination, forwarded_with)
              end
            end
          
          when "MediaEntry"
            [:media_file_id].each do |k|
              h[k] = media_resource.send(k) if with[k]
            end
            if with[:flags]
              h[:can_maybe_browse] = media_resource.meta_data.for_meta_terms.exists?
            end
        end
      end
      
      h
    end
    
    alias :hash_for_media_entry_incomplete :hash_for_media_resource 
    alias :hash_for_media_entry :hash_for_media_resource 
    alias :hash_for_media_set :hash_for_media_resource 

    ###########################################################################

    def hash_for_media_resources_with_pagination(media_resources, pagination, with = nil)
      page = (pagination.is_a?(Hash) ? pagination[:page] : nil) || 1
      per_page = [((pagination.is_a?(Hash) ? pagination[:per_page] : nil) || PER_PAGE.first).to_i, PER_PAGE.first].min
      paginated_media_resources = media_resources.paginate(:page => page, :per_page => per_page)
      {
        pagination: hash_for_pagination(media_resources, paginated_media_resources), 
        media_resources: hash_for(paginated_media_resources, with)
      }
    end

    ###########################################################################

    def hash_for_pagination(media_resources, paginated_media_resources)
      h = {}
      h[:total_media_entries] = media_resources.media_entries.count if media_resources.respond_to? :media_entries 
      h[:total_media_sets] = media_resources.media_sets.count if media_resources.respond_to? :media_sets
      h[:total] = paginated_media_resources.total_entries 
      h[:page] = paginated_media_resources.current_page 
      h[:per_page] = paginated_media_resources.per_page 
      h[:total_pages] = paginated_media_resources.total_pages
      h    
    end

    ###########################################################################

    def hash_for_media_resource_arc(media_resource_arc, with = nil)
      h = {}
      [:parent_id, :child_id, :highlight].each do |k|
        h[k] = media_resource_arc.send(k)
      end
      h
    end

    ###########################################################################

    def hash_for_graph(media_sets)
      h = {nodes: [], links: []}
      media_sets.each do |media_set|
        h[:nodes] << {:id => media_set.id,
                      :name => media_set.title,
                      :img_src => media_set.get_media_file(current_user).try(:thumb_base64, :small) }
        #v2# h[:nodes] << {:name => media_set.title}
        media_set.child_sets.each do |child_set|
          h[:nodes] << {:id => child_set.id,
                        :name => child_set.title,
                        :img_src => child_set.get_media_file(current_user).try(:thumb_base64, :small) } unless h[:nodes].map{|x| x[:id]}.include?(child_set.id)
          h[:links] << {source_id: media_set.id, target_id: child_set.id}
          #v2# h[:links] << {source: media_set.title, target: child_set.title, type: "suit"}
        end
      end
      h
    end

  end
end
      