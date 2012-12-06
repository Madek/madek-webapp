module CurrentPageHelper
 
  def is_my_archive_page?
    current_user and
    request.env["REQUEST_PATH"]== "/"
  end

  def is_explore_page?
    request.env["REQUEST_PATH"].match /^\/explore/
  end

  def is_explore_categories_path?
    request.env["REQUEST_PATH"].match /^\/explore\/\d+$/
  end

  def is_explore_sections_path? (catalog_id, category_id)
    request.env["REQUEST_PATH"].match /^\/explore\/#{catalog_id}\/#{category_id}$/
  end

  def is_explore_sections_or_categories_path? (catalog_id, category_id)
    request.env["REQUEST_PATH"].match /^\/explore\/#{catalog_id}\/#{category_id}/
  end

  def is_explore_media_resources_path? (catalog_id, category_id, section)
    request.env["REQUEST_PATH"].match /^\/explore\/#{catalog_id}\/#{category_id}\/#{section}$/
  end

  def is_root_page?
    request.env["REQUEST_PATH"]== root_path
  end

  def is_search_page?
    current_user and
    request.env["REQUEST_PATH"]== "/search"
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
