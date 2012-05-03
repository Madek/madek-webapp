json.media_resource_arcs @arcs do |json,arc|
  json.extract! arc , :parent_id, :child_id, :highlight
end
