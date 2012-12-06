module CurrentPageHelper
 
  def is_my_archive_page?
    current_user and
    current_page? root_path
  end

  def is_explore_page?
    current_page? explore_path
  end

  def is_explore_categories_path?
    current_page? explore_categories_path
  end

  def is_explore_sections_path? (catalog_id, category_id)
    current_page? explore_sections_path
  end

  def is_explore_sections_or_categories_path? (catalog_id, category_id)
    is_explore_categories_path? or is_explore_sections_path?
  end

  def is_explore_media_resources_path? (catalog_id, category_id, section)
    current_page? explore_media_resources_path
  end

  def is_root_page?
    current_page? root_path
  end

  def is_search_page?
    current_page? search_path
  end

  def is_media_entry_show?
    current_page? :controller => :media_entries, :action => :show
  end

  def is_media_entry_map?
    current_page? :controller => :media_entries, :action => :map
  end

  def is_media_entry_more_data?
    current_page? :controller => :media_entries, :action => :more_data
  end

  def is_media_entry_parents?
    current_page? :controller => :media_entries, :action => :parents
  end

  def is_media_entry_context_group? context_group
    current_page? :controller => :media_entries, :action => :context_group and
    params[:name] == context_group.name
  end
  
end
