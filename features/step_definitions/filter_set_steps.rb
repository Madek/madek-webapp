# encoding: utf-8

When /^I use the create filter set option$/ do
  find("button,a", :text => "Filterset erstellen").click
end

When /^I provide a title$/ do
  @title = Faker::Name.name
  find("input[name='title']").set @title
end

Then /^I am getting redirected to the (new|updated) filter set$/ do |either_or|
  wait_until{ current_path =~ /filter_sets/ }
end

Then /^I can see the provided title and the used filter settings$/ do
  page.should have_content @title
  @used_filter.each do |filter|
    find("a[href*='#{filter[:key_name].gsub(/\s/, "+")}%5D%5Bids%5D%5B%5D=#{filter[:value]}']")
  end
end

When /^I open a filter set$/ do
  @filter_set = @current_user.media_resources.where(:type => "FilterSet").first
  visit filter_set_path @filter_set
end

When /^I edit the filter set settings$/ do
  step 'I use the "Filtereinstellungen ändern" context action'
end

When /^I change the settings for that filter set$/ do
  wait_until { all(".ui-preloader", :visible => true).size == 0 }
  wait_until { all("#ui-side-filter-blocking-layer", :visible => true).size == 0 }
  find("#ui-side-filter-reset").click
  step 'I use some filters'
end

When /^I save these changes$/ do
  find(".primary-button", :text => "Filtereinstellungen speichern").click
end
