# -*- encoding : utf-8 -*-
### I see a ###########

Then /^I see a block of my keywords$/ do
  expect(find "#user_keywords_block").to be
end

Then /^I see a block of resources showing my content$/ do
  expect(find "#latest_user_resources_block" ).to be
end

Then /^I see a block of resources showing my favorites$/ do
  expect(find "#user_favorite_resources_block").to be
end

Then /^I see a block of resources showing content assigned to me$/ do                                                                 [24/1916]
  expect(find "#user_entrusted_resources_block").to be
end

Then /^I see a block of resources showing my last imports$/ do
  expect(find "#latest_user_imports_block").to be
end

Then /^I see a confirmation alert$/ do
  expect{ find(".ui-alert.confirmation",visible: true) }.not_to raise_error
end

Then /^I see a database login$/ do
  expect(find "#external-user" ).to be
end

Then /^I see a filtered list of resources where at least one element has arcs$/ do
  me = MediaEntry.accessible_by_user(@current_user).detect do |me|
    me.meta_data.where(:type => "MetaDatumKeywords").size > 0 and
    me.parents.accessible_by_user(@current_user).size > 0
  end
  @filter = {:meta_data => {:keywords => {:ids => [me.meta_data.where(:type => "MetaDatumKeywords").last.value.first.meta_term_id]}}}
  visit media_resources_path(@filter)
end


Then /^I a see a graph$/ do
  visit "/visualization/my_media_resources"
end

Then /^I see a list of my groups$/ do
  expect(find "#my_groups_block").to be
end

Then /^I see a list of resources$/ do
  visit media_resources_path
  wait_until { all(".ui-resource").size > 0 }
end

Then /^I see a list with all contexts that are connected with media resources that I can access$/ do
  contexts_with_resources = @current_user.individual_contexts.reject do |context|
    not MediaResource.filter(@current_user, {:meta_context_names => [context.name]}).exists?
  end
  contexts_with_resources.each do |context|
    find(".ui-contexts .ui-context[data-name='#{context.name}']")
  end
end

Then /^I see a media entry$/ do
  visit media_resources_path
  wait_until {not all(".ui-resource[data-type='media-entry']").empty?}
end

Then /^I see a popup$/ do
  expect(@popup = find(".ui-tooltip-content")).to be
end

Then /^I see a preview list of contexts that are connected with media resources that I can access$/ do
  contexts_with_resources = @current_user.individual_contexts.reject do |context|
    not MediaResource.filter(@current_user, {:meta_context_names => [context.name]}).exists?
  end
  all(".ui-contexts .ui-context").length > 0 if contexts_with_resources
  all(".ui-contexts .ui-context").each do |ui_context|
    expect(contexts_with_resources.any? {|context| context.name == ui_context[:"data-name"]}).to be true
  end
end

Then /^I see a selection of the images of the teaser set$/ do
  expect( find("#teaser-set").all("img").size).to be > 0
end

Then /^I see a table row with "(.*?)"$/ do |label|
  (expect find(".table")).to have_content label
end

Then /^I see a warning that I will lose unsaved data$/ do
  page.driver.browser.switch_to.alert.text.should =~ /Nicht gespeicherte Daten gehen verloren/
end

Then /^I see a ZHdK\-Login$/ do
  expect(find "#internal-user" ).to be
end

Then /^I see an help tab$/ do
  expect(find "a#to-help").to be
end

Then /^I see an error alert$/ do
  expect{ find(".ui-alert.error",visible: true) }.not_to raise_error
end

Then /^I see an error that I have to provide a name for that group$/ do
  step 'I see an error alert'
end

Then /^I see an error message that the group name has to be present$/ do
  step 'I see an error alert'
end

Then /^I see an error message that the group cannot be deleted if there are more than (\d+) members$/ do |arg1|
  step 'I see an error alert'
end

Then /^I see an explore tab$/ do
  expect(find "a#to-explore").to be
end


Then /^I see at most three elements of the catalog$/ do
  expect( find("#catalog .grid").all("li.ui-resource").size ).to be > 0
  expect( find("#catalog .grid").all("li.ui-resource").size ).to be < 3
end

### I see all ###########

Then /^I see all resources that are inheritancing that context and have any meta data for that context$/ do
  @media_resources = MediaResource.filter(@current_user, {:meta_context_names => [@context.name]})
  expect( find("#ui-resources-list-container .ui-toolbar-header").text ).to include @media_resources.count.to_s
  all(".ui-resource", :visible => true).each do |resource_el|
    id = resource_el["data-id"]
    expect{@media_resources.include? MediaResource.find id}.to be_true
  end
end

Then /^I see all values that are at least used for one resource$/ do
  media_resources = MediaResource.filter(@current_user, {:meta_context_names => [@context.name]})
  meta_data = media_resources.map { |resource| resource.meta_data.for_context @context }.flatten
  meta_data.reject! {|meta_datum| meta_datum.value.blank? }
  meta_data.map(&:value).flatten.map(&:to_s).each do |term|
    step %Q{I can see the text "#{term}"}
  end
end

### I see ....

Then /^I see by default exactly the labels of the sets that have children in the current visualization$/ do
  all(".node:not([data-size='0'])").each do |el|
    expect{el.find(".node_label_title",visible: true)}.not_to raise_error
  end
  all(".node[data-size='0']").each do |el|
    jq =  " $('.node[id=#{el['id']}]').find('.node_label:visible').length "
    (expect page.evaluate_script(jq)).to be_zero
  end
end

Then (/^I see exactly the same number of resources as before$/) do
  expect(find("#resources_counter").text.to_i).to eq @resources_counter
end

Then /^I see one suggested keyword that is randomly picked from the top (\d+) keywords of resources that I can see$/ do |count|
  top_accessible_keywords = Keyword.with_count_for_accessible_media_resources(@current_user).limit(count.to_i)
  found = false
  top_accessible_keywords.each do |keyword|
    found = true if all(".ui-search-input[placeholder*='#{keyword}']").size > 0
  end
  raise "this is not one of the top #{count} accessible keywords" unless found
end

Then /^I see new content$/ do
  expect( find("#latest-media-entries .grid").all("li.ui-resource").size ).to be > 0
end

Then /^I see page for the resource$/ do
  expect(find(".app-body-title h1").text).to eq @resource.title
end

### I see the ###########

Then /^I see the count of MetaData associated to each person$/ do
  wait_until{ all(".meta_data_count").size > 0 }
  expect( all(".meta_data_count").size).to be  > 0
end

Then /^I see the description of the context$/ do
  page.should have_content @context.description.to_s
end

Then /^I see the error\-alert "(.*?)"$/ do |message|
  wait_until{ all('.ui-alert.error',text: message, visible: true).size > 0}
end

Then /^I see the favorite status for that resource$/ do
  expect{@popup.find(".favorite_info i")}.not_to raise_error
end

Then /^I set the input with the name "(.*?)" to the id of a newly created person$/  do |name|
  @person = FactoryGirl.create :person
  find("input[name='#{name}']").set(@person.id)
end

Then /^I see the links to the resource, \(my\-\)descendants, and \(my\)components$/ do
  expect{@popup.find("a#link_for_resource",visible: true)}.not_to raise_error
  expect{@popup.find("a#link_for_component_with",visible: true)}.not_to raise_error
  expect{@popup.find("a#link_for_my_component_with",visible: true)}.not_to raise_error
  expect{@popup.find("a#link_for_my_descendants_of",visible: true)}.not_to raise_error
  expect{@popup.find("a#link_for_descendants_of",visible: true)}.not_to raise_error
end

Then /^I see the links to the resource \(my\)components$/ do
  expect{@popup.find("a#link_for_component_with",visible: true)}.not_to raise_error
  expect{@popup.find("a#link_for_my_component_with",visible: true)}.not_to raise_error
end

Then /^I see the graph after it has finished layouting\/computing$/ do
  wait_until(5){all('#loading',visible: true).size > 0}
  wait_until(10){all('#loading',visible: true).size == 0}
end

Then /^I see the following permissions:$/ do |table|
  table.rows.each do |row|
    user= User.find_by_login row[0]
    expect(find("tr[data-name='#{user.name}'] input[name='#{row[1]}']")).to be_checked
  end
end

Then /^I see the number of children devided by media entry and media set$/ do
  expect(@popup.find(".n_media_sets").text.to_i).to eq(@media_resource.child_media_resources.media_sets.size)
  expect(@popup.find(".n_media_entries").text.to_i).to eq(@media_resource.child_media_resources.media_entries.size)
end

Then /^I see the originating set beeing highlighted$/ do
  wait_until{all("#resource-#{@set.id} .origin").size  > 0 }
end

Then /^I see the originating entry beeing highlighted$/ do
  (expect all("#resource-#{@entry.id} .origin")).not_to be_empty
end

Then /^I see the permission icon for that resource$/ do
  # it suffices to test if there is an icon inside ui-thumbnail-privacy
  expect{ @popup.find(".ui-thumbnail-privacy i") }.not_to raise_error
end

Then /^I see the title of the context$/ do
  page.should have_content @context.label.to_s
end

Then /^I see the title of the entry as graph\-title$/ do
  (expect find(".app")).to have_content @entry.title
end

Then /^I see the title of the set as graph\-title$/ do
  (expect find(".app")).to have_content @set.title
end

Then /^I see the title of that resource$/ do
 expect(@popup.find("h2").text).to eq(@media_resource.title)
end

###

Then /^I see that all labels are show$/ do
  all(".node").each do |el|
    expect{el.find(".node_label_title",visible: true)}.not_to raise_error
  end
end

Then /^I see that none labels are show$/ do
  all(".node").each do |el|
    jq =  " $('.node[id=#{el['id']}]').find('.node_label:visible').length "
    (expect page.evaluate_script(jq)).to be_zero
  end
end

Then /^I see sets of the featured sets$/ do
  expect( find("#featured-set .grid").all("li.ui-resource").size ).to be > 0
end

Then /^I see the column with a number of user resources$/ do
  find("th", text: "# of resources")
end

Then /^I see users list sorted by login$/ do
  users_logins = all("table tbody tr td.user-login").map(&:text)
  expect(users_logins == users_logins.sort).to be_true
end

Then /^I see user list sorted by amount of resources$/ do
  users_resources_amount = all("table tbody tr td.user-resources-amount").map(&:text).map(&:to_i)
  expect(users_resources_amount == users_resources_amount.sort.reverse).to be_true
end

Then /^I see the return link in the navbar$/ do
  link = find('.navbar .navbar-right a')
  expect(link.text).to match /return to user\-interface/
  expect(link[:href]).to eq("/")
  (expect find("th:last").text).not eq("# of resources")
end
