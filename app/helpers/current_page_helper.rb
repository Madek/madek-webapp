module CurrentPageHelper

  def root_page?
    request.fullpath== root_path
  end
 
######### MY ARCHIVE

  def my_archive_page?
    (current_user and @media_set and @media_set.user == current_user) or 
    (current_user and @media_entry and @media_entry.user == current_user) or
    (current_user and @media_resource and @media_resource.user == current_user) or
    my_dashboard_page? or
    my_media_resources_page? or
    my_favorites_page? or
    my_latest_imports_page? or
    my_keywords_page? or
    my_entrusted_media_resources_page? or
    my_groups_page?
  end

  def my_groups_page?
    current_page? my_groups_path
  end

  def my_latest_imports_page?
    current_page? my_latest_imports_path
  end

  def my_dashboard_page?
    current_page? my_dashboard_path
  end

  def my_media_resources_page?
    current_page? my_media_resources_path
  end

  def my_favorites_page?
    current_page? my_favorites_path
  end

  def my_keywords_page?
    current_page? my_keywords_path
  end

  def my_entrusted_media_resources_page?
    current_page? my_entrusted_media_resources_path
  end

  def my_contexts_page?
    current_page? my_contexts_path
  end

######### EXPLORE

  def explore_page?
    request.fullpath.match /^\/explore/
  end

  def explore_catalog_page?
    current_page? explore_catalog_path
  end

  def explore_category_page? (category_id)
    request.fullpath.match /^\/explore\/catalog\/#{category_id}$/
  end

  def explore_category_or_categories_page? (category_id)
    request.fullpath.match /^\/explore\/catalog\/#{category_id}/
  end

  def explore_section_page? (category_id, section)
    current_page? explore_section_path(category_id, section)
  end

  def explore_featured_set_page?
    current_page? explore_featured_set_path
  end

  def explore_keywords_page?
    current_page? explore_keywords_path
  end

  def explore_contexts_page?
    current_page? explore_contexts_path
  end

######### SEARCH

  def search_page?
    request.fullpath[/^\/search/]
  end

######### MEDIA ENTRY

  def media_entry_show_page?
    current_page? :controller => :media_entries, :action => :show
  end

  def media_entry_map_page?
    current_page? :controller => :media_entries, :action => :map
  end

  def media_entry_more_data_page?
    current_page? :controller => :media_entries, :action => :more_data
  end

  def media_entry_parents_page?
    current_page? :controller => :media_entries, :action => :parents
  end

  def media_entry_contexts_page?
    current_page? controller: :media_entries, action: :contexts
  end

######### MEDIA SET

  def media_set_show_page?
    current_page? :controller => :media_sets, :action => :show
  end

  def media_set_parents_page?
    current_page? :controller => :media_sets, :action => :parents
  end

  def media_set_context_page?
    # FIXME: the above throws weird errors. WTF?
    # # current_page? :controller => :media_sets, :action => :individual_contexts
    # workaround:
    (controller.class.to_s === "MediaSetsController") && (controller.action_name === "individual_contexts")
  end

######### CONTEXTS

  def context_show_page?
    current_page? :controller => :contexts, :action => :show
  end
  
  def context_entries_page?
    current_page? context_entries_path
  end
  
end
