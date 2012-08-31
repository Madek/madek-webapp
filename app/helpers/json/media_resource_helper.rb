# -*- encoding : utf-8 -*-

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
              image_media_resource_path(media_resource, :size => size)
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
          media_resources= media_resource.parents.accessible_by_user(current_user)
          h[:parents] = hash_for_media_resources_with_pagination(media_resources, pagination, forwarded_with)
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
                end.accessible_by_user(current_user)
                pagination = ((with[:children].is_a? Hash) ? with[:children][:pagination] : nil) || true
                forwarded_with = (with[:children].is_a? Hash) ? (with[:children][:with]||=nil) : nil
                hash_for_media_resources_with_pagination(media_resources, pagination, forwarded_with, true)
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

    def hash_for_media_resources_with_pagination(media_resources, pagination, with = nil, type_totals = false, with_filter = false)
      page = (pagination.is_a?(Hash) ? pagination[:page] : nil) || 1
      per_page = [((pagination.is_a?(Hash) ? pagination[:per_page] : nil) || PER_PAGE.first).to_i, PER_PAGE.first].min
      paginated_media_resources = media_resources.paginate(:page => page, :per_page => per_page)
      
      pagination = {
        total: paginated_media_resources.total_entries, 
        page: paginated_media_resources.current_page,
        per_page: paginated_media_resources.per_page,
        total_pages: paginated_media_resources.total_pages
      }
      if type_totals
        pagination[:total_media_entries] = media_resources.media_entries.count 
        pagination[:total_media_sets] = media_resources.media_sets.count
      end

      h = {
        pagination: pagination, 
        media_resources: hash_for(paginated_media_resources, with)
      }
      h[:filter] = hash_for_filter(media_resources) if with_filter
      h
    end

    def hash_for_filter(media_resources)
      r = []
      
      # OPTIMIZE this is not construct over media_resources
      r << {
        :label => "Berechtigungen, Ich bin...",
        :name => "preset",
        :filter_type => "permissions",
        :filter_logic => "OR",
        :terms => begin
          permission_presets = PermissionPreset.where (Constants::Actions.reduce(" false ") { |s,action| s + " OR #{action} = true" })
          permission_presets.map do |pp|
            { :id => pp.id, :value => pp.name }
          end
        end 
      }
      
      r << {
        :label => "Eigentümer/in",
        :name => "owner",
        :filter_type => "permissions",
        :filter_logic => "OR",
        :terms => begin
          owners = User.includes(:person)
            .where("users.id in (#{media_resources.select("media_resources.user_id").to_sql}) ")
            .order("people.lastname, people.firstname DESC")
          owners.map do |owner|
            { :id => owner.id, :value => owner.to_s }
          end
        end 
      }
      
      r << {
        :label => "Arbeitsgruppen",
        :name => "group",
        :filter_type => "permissions",
        :filter_logic => "OR",
        :terms => begin
          sub = MediaResource.grouppermissions_not_disallowed(current_user, :view).
                        where("grouppermissions.media_resource_id in (#{media_resources.select("media_resources.user_id").to_sql}) ").
                        select("grouppermissions.group_id")
          groups = Group.where( %Q< groups.id in (#{sub.to_sql})>).order("name ASC")
          groups.map do |group|
            { :id => group.id, :value => group.to_s }
          end
        end 
      }
      
      # TODO define meta_keys on the admin panel ?? or just pick based on the meta_keys#meta_datum_object_type ??
      meta_key_labels = ["keywords", "type", "academic year", "project type", "institutional affiliation"]
      meta_keys = MetaKey.where(:label => meta_key_labels).order("FIELD (label, #{meta_key_labels.map{ |i|  %Q('#{i}') }.join(',')})")  
      meta_keys.each do |meta_key|
        # NOTE terms can be MetaTerm, MetaDepartment or Keyword
        terms = case meta_key.label
          when "keywords"
            MetaTerm.select("meta_terms.*, COUNT(meta_data.media_resource_id) AS count_media_resources").
                    joins("INNER JOIN keywords ON meta_terms.id = keywords.meta_term_id INNER JOIN meta_data ON meta_data.id = keywords.meta_datum_id").
                    group("meta_terms.id")
          when "institutional affiliation"
            MetaDepartment.select("groups.*, COUNT(meta_data.media_resource_id) AS count_media_resources").
                    joins("INNER JOIN meta_data_meta_departments ON groups.id = meta_data_meta_departments.meta_department_id INNER JOIN meta_data ON meta_data.id = meta_data_meta_departments.meta_datum_id").
                    group("groups.id")
          else
            MetaTerm.select("meta_terms.*, COUNT(meta_data.media_resource_id) AS count_media_resources").
                    joins("INNER JOIN meta_data_meta_terms ON meta_terms.id = meta_data_meta_terms.meta_term_id INNER JOIN meta_data ON meta_data.id = meta_data_meta_terms.meta_datum_id").
                    where(:meta_data => {:meta_key_id => meta_key}).
                    group("meta_terms.id")
        end.where("meta_data.media_resource_id IN (#{media_resources.select("media_resources.id").to_sql})")
        k = hash_for(meta_key).merge({
          :label => meta_key.first_context_label,
          :filter_type => "meta_data",
          :terms => terms.map do |term|
            h = hash_for(term).merge({:count => term.count_media_resources})
          end.sort {|a,b| [b[:count], a[:value]] <=> [a[:count], b[:value]] }
        })
        r << k
      end
      r
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
      with = {:meta_data => {:meta_key_names => ["title"]}, :image => {:as => :base64}, :flags => true}
      media_sets.each do |media_set|
        h[:nodes] << hash_for(media_set, with)
        #v2# h[:nodes] << {:name => media_set.title}
        media_set.child_sets.each do |child_set|
          h[:nodes] << hash_for(child_set, with)
          h[:links] << {source_id: media_set.id, target_id: child_set.id}
          #v2# h[:links] << {source: media_set.title, target: child_set.title, type: "suit"}
        end
      end
      h
    end

  end
end
      
