# -*- encoding : utf-8 -*-

module MediaResourceModules
  module Filter

    KEYS = [ :accessible_action, :collection_id, :favorites, :group_id, :ids,
             :media_file,:media_files, :media_set_id, :meta_data, :not_by_user_id,
             :permissions, :public, :search, :top_level, :type, :user_id,
             :query ] 

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods
      def get_filter_params params
        params.select do |k,v| 
          KEYS.include?(k.to_sym) 
        end.delete_if {|k,v| v.blank?}.deep_symbolize_keys
      end

      # returns a chainable collection of media_resources
      # when current_user argument is not provided, the permissions are not considered
      def filter(current_user = nil, filter = {})
        filter = filter.delete_if {|k,v| v.blank?}.deep_symbolize_keys
        raise "invalid option" unless filter.is_a?(Hash) #and (filter.keys - KEYS).blank?

        ############################################################

        filter[:ids] = by_collection(current_user.id, filter[:collection_id]) if current_user and filter[:collection_id]

        ############################################################
        
        resources = if current_user and filter[:favorites] == "true"
          current_user.favorites
        elsif filter[:media_set_id]
          MediaSet.find(filter[:media_set_id]).child_media_resources
        else
          self
        end

        resources = case filter[:type]
          when "media_sets"
            r = resources.media_sets
            r = r.top_level if filter[:top_level]
            r
          when "media_entries"
            resources.media_entries
          when "media_entry_incompletes"
            resources.where(:type => "MediaEntryIncomplete")
          else
            types = ["MediaEntry", "MediaSet", "FilterSet"]
            types << "MediaEntryIncomplete" if filter[:ids]
            resources.where(:type => types)
        end
        
        resources = resources.accessible_by_user(current_user, filter[:accessible_action]) if current_user

        ############################################################
      
        if media_files_filter = filter[:media_files]
          media_files_filter.each do |column,h|
            value =h[:ids].first # we can simplify here, since there can be only one extension/type
            resources = resources.media_entries. # only media entries can have media file
              joins("INNER JOIN media_files ON media_files.id = media_resources.media_file_id").
              where("media_files.#{column} = ?", value)
          end
        end


        ############################################################

        resources = resources.where(:id => filter[:ids]) if filter[:ids]

        resources = resources.search(filter[:search]) unless filter[:search].blank?

        ############################################################
        
        resources = resources.accessible_by_group(filter[:group_id]) if filter[:group_id]

        resources = resources.where(:user_id => filter[:user_id]) if filter[:user_id]

        # FIXME use presets and :manage permission
        resources = resources.not_by_user(filter[:not_by_user_id]) if filter[:not_by_user_id]

        resources = resources.filter_public(filter[:public]) if filter[:public]

        resources = resources.filter_permissions(current_user, filter[:permissions]) if current_user and filter[:permissions]

        ############################################################

        resources = resources.filter_meta_data(filter[:meta_data]) if filter[:meta_data]

        resources = resources.filter_media_file(filter[:media_file]) if filter[:media_file] and filter[:media_file][:content_type]

        resources
      end

      # FIXME doesn't work the chaining when are private methods
      # private

      def filter_public(filter = {})
        case filter
          when "true"
            where(:view => true)
          when "false"
            where(:view => false)
        end
      end

      def filter_permissions(current_user, filter = {})
        resources = scoped
        filter.each_pair do |k,v|
          v[:ids].each do |id|
            resources = case k
              when :owner
                resources.where(:user_id => id)
              when :group
                resources.accessible_by_group(id)
              when :scope
                case id.to_sym
                  when :mine
                    resources.where(:user_id => current_user)
                  when :entrusted
                    resources.entrusted_to_user(current_user)
                  when :public
                    resources.filter_public("true")
                end
            end
          end
        end
        resources
      end
      
      def filter_meta_data(filter = {})
        resources = scoped
        filter.each_pair do |k,v|
          # this is AND implementation
          v[:ids].each do |id|
            # OPTIMIZE resource.joins(etc...) directly intersecting multiple criteria doesn't work, then we use subqueries
            # FIXME switch based on the meta_key.meta_datum_object_type 
            sub = case k
              when :keywords
                s = unscoped.joins(:meta_data).
                         joins("INNER JOIN keywords ON keywords.meta_datum_id = meta_data.id")
                s = s.where(:keywords => {:meta_term_id => id}) unless id == "any"
                s
              when :"institutional affiliation"
                s = unscoped.joins(:meta_data).
                         joins("INNER JOIN meta_data_meta_departments ON meta_data_meta_departments.meta_datum_id = meta_data.id")
                s = s.where(:meta_data_meta_departments => {:meta_department_id => id}) unless id == "any"
                s
              else
                # OPTIMIZE accept also directly meta_key_id ?? 
                s = unscoped.joins(:meta_data => :meta_key).
                         joins("INNER JOIN meta_data_meta_terms ON meta_data_meta_terms.meta_datum_id = meta_data.id").
                         where(:meta_keys => {:label => k, :meta_datum_object_type => "MetaDatumMetaTerms"})
                s = s.where(:meta_data_meta_terms => {:meta_term_id => id}) unless id == "any"
                s
            end
            resources = resources.where("media_resources.id IN  (#{sub.select("media_resources.id").to_sql})")
          end
        end
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



