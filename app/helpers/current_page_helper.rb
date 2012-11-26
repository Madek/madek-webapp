module CurrentPageHelper
 
  def is_my_archive_page
    current_user and
    request.env["REQUEST_PATH"]== "/"
  end

  def is_explore_page
    request.env["REQUEST_PATH"]== "/explore"
  end

  def is_search_page
    current_user and
    request.env["REQUEST_PATH"]== "/search"
  end

end
