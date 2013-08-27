
def stable_part_of_meta_datum_departement dep_name
  dep_name.match(/^(.*)\(/).captures.first
end
