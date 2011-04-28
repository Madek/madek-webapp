module Logic
  extend self

  def data_for_page(media_entry_ids, current_user)
    media_entries = MediaEntry.includes(:media_file).find(media_entry_ids)

    editable_ids = current_user.accessible_resource_ids(:edit)
    managable_ids = current_user.accessible_resource_ids(:manage)
    favorite_ids = current_user.favorite_ids
    
    editable_in_context = editable_ids & media_entry_ids
    managable_in_context = managable_ids & media_entry_ids

    { :pagination => { :current_page => media_entry_ids.current_page,
                       :per_page => media_entry_ids.per_page,
                       :total_entries => media_entry_ids.total_entries,
                       :total_pages => media_entry_ids.total_pages },
      :entries => media_entries.map do |me|
                    flags = { :is_private => me.acl?(:view, :only, current_user),
                              :is_public => me.acl?(:view, :all),
                              :is_editable => editable_in_context.include?(me.id),
                              :is_manageable => managable_in_context.include?(me.id),
                              :is_favorite => favorite_ids.include?(me.id) }
                    me.attributes.merge(me.get_basic_info).merge(flags)
                  end } 
  end

########################################################  
  
  def enriched_resource_data(resources, current_user)
    media_entries = resources.select{ |r| r.class.name == "MediaEntry" }
    media_sets = resources.select{ |r| r.class.base_class.name == "Media::Set" }
    
    media_entry_ids = media_entries.map(&:id)
    media_set_ids = media_sets.map(&:id)
    
    editable_media_entry_ids = current_user.accessible_resource_ids(:edit)
    managable_media_entry_ids = current_user.accessible_resource_ids(:manage)
    
    editable_media_set_ids = current_user.accessible_resource_ids(:edit, Media::Set)
    managable_media_set_ids = current_user.accessible_resource_ids(:manage, Media::Set)
    # only to be applied to ME
    favorite_ids = current_user.favorite_ids
    
    # intersections
    editable_media_entries_in_context = editable_media_entry_ids & media_entry_ids
    managable_media_entries_in_context = managable_media_entry_ids & media_entry_ids
    
    editable_media_sets_in_context = editable_media_set_ids & media_set_ids
    managable_media_sets_in_context = managable_media_set_ids & media_set_ids
    
    
    enriched_media_entries = media_entries.map do |me|
      flags = { :is_private => me.acl?(:view, :only, current_user),
                :is_public => me.acl?(:view, :all),
                :is_editable => editable_media_entries_in_context.include?(me.id),
                :is_manageable => managable_media_entries_in_context.include?(me.id),
                :is_set => false,
                :is_favorite => favorite_ids.include?(me.id)}
      me.attributes.merge(me.get_basic_info).merge(flags)
    end 
    
    enriched_media_sets = media_sets.map do |set|
      flags = { :is_private => set.acl?(:view, :only, current_user),
                :is_public => set.acl?(:view, :all),
                :is_editable => editable_media_sets_in_context.include?(set.id),
                :is_manageable => managable_media_sets_in_context.include?(set.id),
                :is_set => true }
      set.attributes.merge(set.get_basic_info).merge(flags)
    end
    
    {:pagination => { :current_page => resources.current_page,
                       :per_page => resources.per_page,
                       :total_entries => resources.total_entries,
                       :total_pages => resources.total_pages },        
      :entries => enriched_media_entries + enriched_media_sets }
  end


end
