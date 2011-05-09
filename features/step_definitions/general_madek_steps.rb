Given /^I have set up the world$/ do
  # Set this to a non-JS driver because:
  # 1. The Selenium driver times out during this step
  # 2. This step may be called in backgrounds of tests that have
  #    :js => true, so this would break this step. Therefore
  #    we set our own driver here.
  old_driver = Capybara.current_driver
  Capybara.use_default_driver

  if MetaKey.count == 0 # TODO: Test for more stuff, just having more than 0
                        # keys doesn't guarantee the YAML file has already been
                        # loaded.
    steps %Q{
      Given a user called "Bruce Willis" with username "bruce_willis" and password "fluffyKittens" exists
      And a group called "Admin" exists
      And the user with username "bruce_willis" is member of the group "Admin"
      And I log in as "bruce_willis" with password "fluffyKittens"
    }

    click_on_arrow_next_to("Willis, Bruce")
    click_link("Admin")
    click_link("Import")
    attach_file("uploaded_data", Rails.root + "features/data/minimal_meta.yml")
    click_button("Import »")
    
  end

  MetaKey.count.should == 89
  Capybara.current_driver = old_driver

  # This is actually normally called in the seeds, but
  # the RSpec developers don't believe in using seeds, so
  # they drop the database even if we seed it before running
  # the tests. Therefore we recreate our world in this step.
  Copyright.init
  Permission.init
  Meta::Department.fetch_from_ldap
  Meta::Date.parse_all

end

Given /^a user called "([^"]*)" with username "([^"]*)" and password "([^"]*)" exists$/ do |person_name, username, password|
  user = User.where(:login => username).first
  if user.nil?
    firstname, lastname = person_name, person_name
    firstname, lastname = person_name.split(" ") if person_name.include?(" ")
    crypted_password = Digest::SHA1.hexdigest(password)
    person = Person.find_or_create_by_firstname_and_lastname(:firstname => firstname,
                                                            :lastname => lastname)
    user = person.build_user(:login => username,
                             :email => "#{username}@zhdk.ch",
                             :password => crypted_password)
    user.usage_terms_accepted_at = DateTime.now
    user.save.should == true
  end
end

Given /^the user with username "([^"]*)" is member of the group "([^"]*)"/ do |username, groupname|
  user = User.where(:login => username).first
  group = Group.where(:name => groupname).first
  user.groups << group unless user.groups.include?(group)
  user.save.should == true
end

Given /^I log in as "(\w+)" with password "(\w+)"$/ do |username, password|
  visit "/logout"
  visit "/db/login"
  fill_in "login", :with => username
  fill_in "password", :with => password
  click_link_or_button "Log in"
end

Given /^a group called "([^"]*)" exists$/ do |groupname|
  create_group(groupname)
end

When /^I debug$/ do
  debugger; puts "lala"
end

When /^I upload some picture titled "([^"]*)"$/ do |title|
  upload_some_picture(title)
end

When /^I wait for the CSS element "([^"]*)"$/ do |css|
  wait_for_css_element(css)
end

When /^I fill in the set title with "([^"]*)"/ do |title|
  fill_in find("#text_media_set").find("input")[:id], :with => title
end


When /I fill in the metadata for entry number (\d+) as follows:/ do |num, table|
  # Makes the text more human-readable, don't have to specify 0 to fill in
  # for the first entry
  media_entry_num = num.to_i - 1
  # Fills in the "_value" field it finds in the UL that contains
  # the "key" text. e.g. "Titel*" or "Copyright"
  table.hashes.each do |hash|
    text = filter_string_for_regex(hash['label'])
    all("ul", :text => /^#{text}/)[media_entry_num].all("input").each do |ele|
      fill_in ele[:id], :with => hash['value'] if ele[:id] =~ /_value$/
    end
  end
end

When "I fill in the metadata form as follows:" do |table|
  table.hashes.each do |hash|
    # Fills in the "_value" field it finds in the UL that contains
    # the "key" text. e.g. "Titel*" or "Copyright"
    text = filter_string_for_regex(hash['label'])

    list = find("ul", :text => /^#{text}/)
    if list.nil?
      puts "Can't find any input fields with the text '#{text}'"
    else
      if list[:class] == "Person"
        fill_in_person_widget(list, hash['value'], hash['options'])
      elsif list[:class] == "Keyword"
        fill_in_keyword_widget(list, hash['value'], hash['options'])
      elsif list[:class] == "Meta::Term"
        if list.has_css?("ul.meta_terms")
          set_term_checkbox(list, hash['value'])
        elsif list.has_css?(".madek_multiselect_container")
          select_from_multiselect_widget(list, hash['value'])
        else
          puts "Unknown Meta::Term interface element when trying to set '#{text}'"
        end
      elsif list[:class] == "Meta::Department"
        select_from_multiselect_widget(list, hash['value'])
      else
        # These can be either textareas or input fields, let's fill in both. It's a bit brute force,
        # can be done more elegantly by finding out whether we're dealing with a textarea or an input field.
        list.all("textarea").each do |ele|
          fill_in ele[:id], :with => hash['value'] if !ele[:id].match(/meta_data_attributes_.+_value$/).nil? and ele[:id].match(/meta_data_attributes_.+_keep_original_value$/).nil?
        end
        
        list.all("input").each do |ele|
          fill_in ele[:id], :with => hash['value'] if !ele[:id].match(/meta_data_attributes_.+_value$/).nil? and ele[:id].match(/meta_data_attributes_.+_keep_original_value$/).nil?
        end
        
      end
      
    end

  end
end


When /^(?:|I )attach the file "([^"]*)" relative to the Rails directory to "([^"]*)"(?: within "([^"]*)")?$/ do |path, field, selector|
  path = Rails.root + path
  within_string = selector.blank? ? "" : " within \"#{selector}\""
  When "I attach the file \"#{path}\" to \"#{field}\"" + within_string
end

When "Sphinx is forced to reindex" do
  sphinx_reindex
end

# Can use "user" or "group" field name
When /^I type "([^"]*)" into the "([^"]*)" autocomplete field$/ do |string, field|
  type_into_autocomplete(field.to_sym, string)
end

When /^I pick "([^"]*)" from the autocomplete field$/ do |choice|
  pick_from_autocomplete(choice)
end

When /^I give "([^"]*)" permission to "([^"]*)"$/ do |permission, subject|
  subject = :everybody if subject == "everybody"
  give_permission_to(permission, subject)
end

When /^I remove "([^"]*)" permission from "([^"]*)"$/ do |permission, subject|
  subject = :everybody if subject == "everybody"
  remove_permission_to(permission, subject)
end

When /^I click(?: | on )the arrow next to "([^"]*)"/ do |string|
  click_on_arrow_next_to(string)
end

When /^I click the media entry titled "([^"]*)"/ do |title|
  click_media_entry_titled(title)
end

When /^I check the media entry titled "([^"]*)"/ do |title|
  check_media_entry_titled(title)
end

When /^I create a set titled "([^"]*)"/ do |title|
  create_set(title)
end

When /^I add the picture "([^"]*)" to the set "([^"]*)"/ do |picture_title, set_title|
    add_to_set(set_title, picture_title)
end

When /^I toggle the favorite star on the media entry titled "([^"]*)"$/ do |title|
  entry = find_media_entry_titled(title)
  entry.find(:css, ".favorite_link").find("a").click
  sleep(0.5)
end

When /^I click the edit icon on the media entry titled "([^"]*)"$/ do |title|
  entry = find_media_entry_titled(title)
  entry.all("a").each do |link|
    link.click if link[:title] == "Editieren"
  end
  sleep(0.5)
end

When /^I click the delete icon on the media entry titled "([^"]*)"$/ do |title|
  entry = find_media_entry_titled(title)
   entry.all("a").each do |link|
     # Fake some functions so that we automatically accept the confirmation dialog
     page.evaluate_script("window.alert = function(msg) { return true; }")
     page.evaluate_script("window.confirm = function(msg) { return true; }")
     link.click if link[:title] == "Löschen"
   end
  sleep(0.5)
end

When /^I press enter in the input field "([^"]*)"$/ do |field|
  press_enter_in(field)
end

When "I toggle the favorite star on this media entry" do
  find(:css, ".favorite_link").find("a").click
  sleep(0.5)
end

When "all the hidden items become visible" do
  make_hidden_items_visible
end

When "I make sure I'm logged out" do
  if page.has_content?("Abmelden")
    Then 'I follow "Abmelden"'
  end
end

When /I filter by "([^"]*)" in "([^"]*)"$/ do |choice, category|
  header = find("h3.filter_category", :text => category)  
  header.find("a.filter_category_link").click
  # Finds the div underneath the h3 title, so that we can manipulate the form there (e.g. click some checkboxes to
  # filter by controlled vocabulary)
  form_div = find("#filter-query").find(:xpath, ".//h3[contains(.,'#{category}')]/following::*")
  lis = form_div.all("li")

#   debugger; puts "lala"
  lis.each do |li|
    unless (li.text =~ /^#{choice} \(\d+\)$/).nil?
      cb = li.find("input")
      cb.click unless cb[:checked] == "true"
    end
  end
  
end


Then "the box should have a hires download link" do
    find(:css, "tr.download-unit").all("a").count.should == 1
end

Then "the box should not have a hires download link" do
    find(:css, "tr.download-unit").all("a").count.should == 0
end
