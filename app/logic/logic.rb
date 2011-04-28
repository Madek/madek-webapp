module Logic
  extend self

  def data_for_page(media_entry_ids, current_user)
    media_entries = MediaEntry.includes(:media_file).find(media_entry_ids)

    editable_ids = Permission.accessible_by_user("MediaEntry", current_user, :edit)
    managable_ids = Permission.accessible_by_user("MediaEntry", current_user, :manage)
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

# def enriched_resource_data(resources, current_user)
#   media_entries = resources.select{ |r| r.class.name == "MediaEntry" }
#   media_sets = resources.select{ |r| r.class.base_class.name == "Media::Set" }
#   
#   media_entry_ids = media_entries.map(&:id)
#   media_set_ids = media_sets.map(&:id)
#   
#   editable_media_entry_ids = Permission.accessible_by_user("MediaEntry", current_user, :edit)
#   managable_media_entry_ids = Permission.accessible_by_user("MediaEntry", current_user, :manage)
#   
#   editable_media_set_ids = Permission.accessible_by_user("Media::Set", current_user, :edit)
#   managable_media_set_ids = Permission.accessible_by_user("Media::Set", current_user, :manage)
#   # only to be applied to ME
#   favorite_ids = current_user.favorite_ids
#   
#   # intersections
#   editable_media_entries_in_context = editable_media_entry_ids & media_entry_ids
#   managable_media_entries_in_context = managable_media_entry_ids & media_entry_ids
#   
#   editable_media_sets_in_context = editable_media_set_ids & media_set_ids
#   managable_media_sets_in_context = managable_media_set_ids & media_set_ids
#   
#   
#   enriched_media_entries = media_entries.map do |me|
#     flags = { :is_private => me.acl?(:view, :only, current_user),
#               :is_public => me.acl?(:view, :all),
#               :is_editable => editable_media_entries_in_context.include?(me.id),
#               :is_manageable => managable_media_entries_in_context.include?(me.id),
#               :is_set => false,
#               :is_favorite => favorite_ids.include?(me.id)}
#     me.attributes.merge(me.get_basic_info).merge(flags)
#   end 
#   
#   enriched_media_sets = media_sets.map do |set|
#     flags = { :is_private => set.acl?(:view, :only, current_user),
#               :is_public => set.acl?(:view, :all),
#               :is_editable => editable_media_sets_in_context.include?(set.id),
#               :is_manageable => managable_media_sets_in_context.include?(set.id),
#               :is_set => true }
#     set.attributes.merge(set.get_basic_info).merge(flags)
#   end
#   
#   {:pagination => { :current_page => resources.current_page,
#                      :per_page => resources.per_page,
#                      :total_entries => resources.total_entries,
#                      :total_pages => resources.total_pages },        
#     :entries => enriched_media_entries + enriched_media_sets }
# end

  
  def enriched_resource_data(resources, current_user, resource_type)    
    resource_ids = resources.map(&:id)
    
    editable_ids = Permission.accessible_by_user(resource_type, current_user, :edit)
    managable_ids = Permission.accessible_by_user(resource_type, current_user, :manage)
    favorite_ids = current_user.favorite_ids if resource_type == "MediaEntry"
    
    # intersections
    editable_in_context = editable_ids & resource_ids
    managable_in_context = managable_ids & resource_ids
  
    enriched_resources = resources.map do |res|
      flags = { :is_private => res.acl?(:view, :only, current_user),
                :is_public => res.acl?(:view, :all),
                :is_editable => editable_in_context.include?(res.id),
                :is_manageable => managable_in_context.include?(res.id) }
      all_attributes = res.attributes.merge(res.get_basic_info).merge(flags)
      all_attributes.merge(:is_favorite => favorite_ids.include?(res.id)) if resource_type == "MediaEntry"
      all_attributes
    end
    
    {:pagination => { :current_page => resources.current_page,
                       :per_page => resources.per_page,
                       :total_entries => resources.total_entries,
                       :total_pages => resources.total_pages },
      :entries => enriched_resources }
  end


end
