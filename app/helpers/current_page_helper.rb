module CurrentPageHelper

  def root_page?
    request.fullpath== root_path
  end
 
######### MY ARCHIVE

  def my_archive_page?
    (current_user and request.fullpath== "/") or
    (current_user and @media_set and @media_set.user == current_user) or 
    (current_user and @media_entry and @media_entry.user == current_user) or
    (current_user and @media_resource and @media_resource.user == current_user) or
    my_media_resources_page? or 
    my_favorites_page? or
    my_keywords_page? or 
    my_entrusted_media_resources_page?
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

  def media_entry_context_group_page? context_group
    current_page? :controller => :media_entries, :action => :context_group and
    params[:name] == context_group.name
  end
  
######### MEDIA SET

  def media_set_show_page?
    current_page? :controller => :media_sets, :action => :show
  end

  def media_set_parents_page?
    current_page? :controller => :media_sets, :action => :parents
  end

  def media_set_inheritable_contexts_page?
    current_page? :controller => :media_sets, :action => :inheritable_contexts
  end

  def media_set_abstract_page?
    current_page? :controller => :media_sets, :action => :abstract
  end

  def media_set_vocabulary_page?
    current_page? :controller => :media_sets, :action => :vocabulary
  end
  
end
