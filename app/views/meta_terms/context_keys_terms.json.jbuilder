json.(@meta_context,:id,:name,:is_user_interface)
json.meta_key_definitions @meta_context.meta_key_definitions do |json,mkd|
  json.(mkd,:id,:position,:is_required,:label,:hint,:description)
  json.meta_key do |json|
    json.type mkd.meta_key.object_type || "String"
  end
end
