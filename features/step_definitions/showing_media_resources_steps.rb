Then(/^I can see exactly "(.*?)" included resources$/) do |snum|
  wait_until{ all("ul#ui-resources-list li.ui-resource").size == snum.to_i }
end

Then(/^I can see at least "(.*?)" included resources$/) do |snum|
  wait_until(3*Capybara.default_wait_time){ all("ul#ui-resources-list li.ui-resource").size >= snum.to_i }
end

Given(/^There is a movie with previews and public viewing\-permission$/) do
  System.execute_cmd! "tar xf #{Rails.root.join "features/data/media_files_with_movie.tar.gz"} -C #{Rails.root.join  "db/media_files/", Rails.env}"
  @movie = MediaResource.find 113
  binding.pry
end

When(/^I visit the page of that movie$/) do
  visit media_resource_path(@movie)
end
