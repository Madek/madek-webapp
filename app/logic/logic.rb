# -*- encoding : utf-8 -*-
module Logic
  extend self

  def data_for_page(media_entry_ids, current_user)
    media_entries = MediaEntry.find(media_entry_ids)

    { :pagination => { :current_page => media_entry_ids.current_page,
                       :per_page => media_entry_ids.per_page,
                       :total_entries => media_entry_ids.total_entries,
                       :total_pages => media_entry_ids.total_pages },
      :entries => media_entries.as_json({:user => current_user})
    } 
  end

########################################################
  
  def enriched_resource_data(resource_ids, current_user, resource_type)
    resources = resource_type.constantize.find(resource_ids)

    editable_ids = current_user.accessible_resource_ids(:edit, resource_type)
    managable_ids = current_user.accessible_resource_ids(:manage, resource_type)

    favorite_ids = current_user.favorite_ids if resource_type == "MediaEntry"
    
    # intersections
    editable_in_context = editable_ids & resource_ids
    managable_in_context = managable_ids & resource_ids
  
    enriched_resources = resources.map do |res|
      flags = { :is_private => res.acl?(:view, :only, current_user),
                :is_public => res.acl?(:view, :all),
                :is_editable => editable_in_context.include?(res.id),
                :is_manageable => managable_in_context.include?(res.id),
                :can_maybe_browse => !res.meta_data.for_meta_terms.blank? }
      all_attributes = res.attributes.merge(res.get_basic_info(current_user)).merge(flags)
      all_attributes.merge!(:url_stub => (resource_type == "MediaEntry") ? "media_entries" : "media_sets")
      all_attributes.merge!(:is_set => resource_type != "MediaEntry")
      all_attributes.merge!(:is_favorite => favorite_ids.include?(res.id)) if resource_type == "MediaEntry"
      all_attributes
    end
    
    pagination_label = case resource_type
      when "MediaEntry"
        "Medieneinträge"
      when "Media::Set"
        "Sets"
      when "Media::Project"
        "Projekte"
      end
    
    {:pagination => { :current_page => resource_ids.current_page,
                       :per_page => resource_ids.per_page,
                       :total_entries => resource_ids.total_entries,
                       :total_pages => resource_ids.total_pages,
                       :pagination_label => pagination_label },
      :entries => enriched_resources }
  end


end
