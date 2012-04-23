json.array!(@arcs) do |json,arc|
  json.extract! arc , :parent_id, :child_id, :highlight
end
