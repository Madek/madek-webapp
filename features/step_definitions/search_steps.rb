When /^I go to the search page$/ do
  visit search_path
end

Then /^I see one suggested keyword that is randomly picked from the top (\d+) keywords of resources that I can see$/ do |count|
  top_accessible_keywords = Keyword.with_count_for_accessible_media_resources(@current_user).limit(count.to_i)
  found = false
  top_accessible_keywords.each do |keyword|
    found = true if all(".ui-search-input[placeholder*='#{keyword}']").size > 0
  end
  raise "this is not one of the top #{count} accessible keywords" unless found
end