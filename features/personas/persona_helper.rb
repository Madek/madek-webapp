
# Some utility functions to use while creating personas, to reduce the
# amount of duplicated code

def md_attribute(label, value)
  {:meta_key_id => MetaKey.find_by_label(label).id, :value => value}
end

def md_attributes(attributes)
  attrib_hash = {}
  attributes.each_with_index do |a, index|
    attrib_hash[index] = a
  end
  return attrib_hash
end
