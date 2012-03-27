json.meta_context  do |json|
  json.(@meta_context,:id,:name,:is_user_interface)
  json.meta_key_definitions @meta_context.meta_key_definitions do |json,mkd|
    json.(mkd,:id,:position,:is_required,:label,:hint,:description)
  end
end
