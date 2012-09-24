# -*- encoding : utf-8 -*-

module MediaResourceModules
  module Filter

    KEYS = [ :accessible_action, :collection_id, :favorites, :group_id, :ids,
             :media_file, :media_set_id, :meta_data, :not_by_current_user,
             :permissions, :public, :search, :top_level, :type, :user_id,
             :query ] 
    
    DEPRECATED_KEYS = {:search => :query}

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods
      # returns a chainable collection of media_resources
      def filter(current_user, filter = {})
        filter = filter.delete_if {|k,v| v.blank?}.deep_symbolize_keys
        raise "invalid option" unless filter.is_a?(Hash) #and (filter.keys - KEYS).blank?

        DEPRECATED_KEYS.each_pair do |k,v|
          filter[k] ||= filter.delete(v) if filter[v]
        end

        ############################################################

        filter[:ids] = by_collection(current_user.id, filter[:collection_id]) if filter[:collection_id]

        ############################################################
        
        resources = if filter[:favorites] == "true"
          current_user.favorites
        elsif filter[:media_set_id]
          media_set = MediaSet.find(filter[:media_set_id])
          media_set.children
        else
          self
        end

        resources = case filter[:type]
          when "media_sets"
            r = resources.where(:type => "MediaSet")
            r = r.top_level if filter[:top_level]
            r
          when "media_entries"
            resources.where(:type => "MediaEntry")
          when "media_entry_incompletes"
            resources.where(:type => "MediaEntryIncomplete")
          else
            if filter[:ids]
              resources.where(:type => ["MediaEntry", "MediaSet", "MediaEntryIncomplete"])
            else
              resources.where(:type => ["MediaEntry", "MediaSet"])
            end
        end.accessible_by_user(current_user, filter[:accessible_action])

        ############################################################

        resources = resources.where(:id => filter[:ids]) if filter[:ids]

        resources = resources.search(filter[:search]) unless filter[:search].blank?

        ############################################################
        
        resources = resources.accessible_by_group(Group.find(filter[:group_id])) if filter[:group_id]

        resources = resources.by_user(User.find(filter[:user_id])) if filter[:user_id]

        # FIXME use presets and :manage permission
        resources = resources.not_by_user(current_user) if filter[:not_by_current_user]
        
        resources = case filter[:public]
          when "true"
            resources.where(:view => true)
          when "false"
            resources.where(:view => false)
        end if filter[:public]

        filter[:permissions].each_pair do |k,v|
=begin
          # this is AND implementation
          v[:ids].each do |id|
            resources = case k
              when :preset
                presets = PermissionPreset.where(:id => id)
                resources.where_permission_presets_and_user presets, current_user
              when :owner
                resources.where(:user_id => id)
              when :group
                resources.where( %Q< media_resources.id  in (
                  #{grouppermissions_not_disallowed(current_user, :view)
                     .where("grouppermissions.group_id in ( ? )", id)
                     .select("media_resource_id").to_sql})>)
            end
          end
=end
          # this is OR implementation
          resources = case k
            when :preset
              presets = PermissionPreset.where(:id => v[:ids])
              resources.where_permission_presets_and_user presets, current_user
            when :owner
              resources.where(:user_id => v[:ids])
            when :group
              resources.where( %Q< media_resources.id  in (
                #{grouppermissions_not_disallowed(current_user, :view)
                    .where("grouppermissions.group_id in ( ? )", v[:ids])
                    .select("media_resource_id").to_sql})>)
          end
        end if filter[:permissions]

        ############################################################

        resources = resources.filter_media_file(filter[:media_file]) if filter[:media_file] and filter[:media_file][:content_type]

        ############################################################

        filter[:meta_data].each_pair do |k,v|
          # this is AND implementation
          v[:ids].each do |id|
            # OPTIMIZE resource.joins(etc...) directly intersecting multiple criteria doesn't work, then we use subqueries
            # FIXME switch based on the meta_key.meta_datum_object_type 
            sub = case k
              when :keywords
                joins(:meta_data).
                joins("INNER JOIN keywords ON keywords.meta_datum_id = meta_data.id").
                where(:keywords => {:meta_term_id => id})
              when :"institutional affiliation"
                joins(:meta_data).
                joins("INNER JOIN meta_data_meta_departments ON meta_data_meta_departments.meta_datum_id = meta_data.id").
                where(:meta_data_meta_departments => {:meta_department_id => id})
              else
                # OPTIMIZE accept also directly meta_key_id ?? 
                joins(:meta_data => :meta_key).
                joins("INNER JOIN meta_data_meta_terms ON meta_data_meta_terms.meta_datum_id = meta_data.id").
                where(:meta_keys => {:label => k, :meta_datum_object_type => "MetaDatumMetaTerms"},
                      :meta_data_meta_terms => {:meta_term_id => id})
            end
            resources = resources.where("media_resources.id IN  (#{sub.select("media_resources.id").to_sql})")
          end
        end if filter[:meta_data]

        ############################################################

        resources
      end

      def filter_media_file(options = {})
        sql = media_entries.joins("RIGHT JOIN media_files ON media_resources.media_file_id = media_files.id")
      
        # OPTIMIZE this is mutual exclusive in case of many media_types  
        options[:content_type].each do |x|
          sql = sql.where("media_files.content_type #{SQLHelper.ilike} ?", "%#{x}%")
        end if options[:content_type]
        
        [:width, :height].each do |x|
          if options[x] and not options[x][:value].blank?
            operator = case options[x][:operator]
              when "gt"
                ">"
              when "lt"
                "<"
              else
                "="
            end
            sql = sql.where("media_files.#{x} #{operator} ?", options[x][:value])
          end
        end
    
        unless options[:orientation].blank?
          operator = if options[:orientation].size == 2
            "="
          else
            case options[:orientation].to_i
              when 0
                "<"
              when 1
                ">"
            end
          end
          sql = sql.where("media_files.height #{operator} media_files.width")
        end
    
        sql    
      end
      
    end

  end
end



