
def stable_part_of_meta_datum_departement dep_name
  dep_name.match(/^(.*)\(/).captures.first
end

When /^Delete unused meta term$/ do
  MetaTerm.create!(term: "UNUSED META TERM")
  step 'I select "Not used" from the select node with the name "filter_by"'
  step 'I submit'
  step 'I click on "Delete"'
  step 'I can see a success message'
end
