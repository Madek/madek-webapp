class MediaResourceCollection < MediaResource

  def included_resources_accessible_by_user user, action
    raise "Implement me" 
  end

end

