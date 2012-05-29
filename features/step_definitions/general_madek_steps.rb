# coding: UTF-8

Given /^I have set up the world$/ do
  # Set this to a non-JS driver because:
  # 1. The Selenium driver times out during this step
  # 2. This step may be called in backgrounds of tests that have
  #    :js => true, so this would break this step. Therefore
  #    we set our own driver here.
  old_driver = Capybara.current_driver
  Capybara.use_default_driver
  Capybara.current_driver = old_driver

  DataFactory.reset_data
  
  # Check setted minimal meta 
  meta_filepath = "#{Rails.root}/features/data/minimal_meta.yml"
  minimal_meta = YAML::load_file(meta_filepath)
  MetaKey.count.should == minimal_meta[:meta_keys].count
  MetaContext.count.should == minimal_meta[:meta_contexts].count
  MetaKeyDefinition.count.should == minimal_meta[:meta_key_definitions].count
  MetaTerm.count.should == minimal_meta[:meta_terms].count
  UsageTerm.count.should == 1
 
  # This is actually normally called in the seeds, but the RSpec developers don't believe in using seeds,
  # so they drop the database even if we seed it before running the tests. Therefore we recreate our world in this step. 
  MetaDepartment.setup_ldapdata_from_localfile
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
    user.usage_terms_accepted_at = DateTime.now + 10.years
    user.save.should == true
  end
end

Given /^the user with username "([^"]*)" is member of the group "([^"]*)"/ do |username, groupname|
  user = User.where(:login => username).first
  group = Group.where(:name => groupname).first
  user.groups << group unless user.groups.include?(group)
  user.save.should == true
end

# Uses the browser to log in
Given /^I log in as "(\w+)" with password "(\w+)"$/ do |username, password|
  visit "/logout"
  visit "/db/login"
  fill_in "login", :with => username
  fill_in "password", :with => password
  click_link_or_button "Log in"
  page.should_not have_content "Invalid username/password"
  
  # NOTE needed for "upload_some_picture" method # TODO merge with "I am logged in as ..." step
  crypted_password = Digest::SHA1.hexdigest(password)
  @current_user = User.where(:login => username, :password => crypted_password).first
  @current_user.should_not be_nil
end

# Gives you a user object
Given /^I am logged in as "(\w+)"$/ do |username|
  @current_user = User.find_by_login(username)
  @current_user ||= FactoryGirl.create(:user, {:login => username})
end

Given /^a group called "([^"]*)" exists$/ do |groupname|
  create_group(groupname)
end

Given /^a set titled "(.+?)" created by "(.+?)" exists$/ do |title, username|
  user = User.where(:login => username).first
  meta_data = {:meta_data_attributes => {0 => {:meta_key_id => MetaKey.find_by_label("title").id, :value => title}}}
  set = user.media_sets.create(meta_data)
end

Given /^a set was created at "(.+?)" titled "(.+?)" by "(.+?)"$/ do |date, title, username|
  user = User.where(:login => username).first
  meta_data = {:meta_data_attributes => {0 => {:meta_key_id => MetaKey.find_by_label("title").id, :value => title}}}
  set = user.media_sets.create(meta_data)
  set.created_at = Date.parse(date)
end

Given /^a public set titled "(.+)" created by "(.+)" exists$/ do |title, username|
  user = User.where(:login => username).first
  meta_data = {:meta_data_attributes => {0 => {:meta_key_id => MetaKey.find_by_label("title").id, :value => title}}}
  set = user.media_sets.create(meta_data)
  set.view= true
  set.save!
end

Given /^a entry titled "(.+)" created by "(.+)" exists$/ do |title, username|
  user = User.where(:login => username).first
  mock_media_entry(user, title)
end

Given /^the last entry is child of the (.+) set/ do |offset|
  if offset == "last"
    parent_set = MediaSet.all.sort_by(&:id).last
  entry = MediaEntry.all.sort_by(&:id).last
  parent_set.media_entries << entry
  else
    parent_set = MediaSet.all.sort_by(&:id)[offset.to_i-1]
    entry = MediaEntry.all.sort_by(&:id).last
    parent_set.media_entries << entry
  end
end

Given /^the last set is parent of the (.+) set$/ do |offset|
  parent_set = MediaSet.all.sort_by(&:id).last
  child_set = MediaSet.all.sort_by(&:id)[offset.to_i-1]
  parent_set.child_sets << child_set
end

Given /^the last set is child of the (.+) set$/ do |offset|
  child_set = MediaSet.all.sort_by(&:id).last
  parent_set = MediaSet.all.sort_by(&:id)[offset.to_i-1]
  parent_set.child_sets << child_set
end

When /^I debug$/ do
  debugger; puts "lala"
end

When /^I pry/ do
   binding.pry
end 

When /^I use pry$/ do
  binding.pry
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
  wait_until { find(".edit_meta_datum_field") and find(".thumb_box") and all(".loading", :visible => true).size == 0 }
  
  # Makes the text more human-readable, don't have to specify 0 to fill in
  # for the first entry
  media_entry_num = num.to_i - 1
  
  # select media_entry wanted
  all(".thumb_box")[media_entry_num].click()
  
  table.hashes.each do |hash|
    label = hash["label"]
    field = find(".label", :text => label).find(:xpath, "./../..")
    input = field.find("input, textarea")
    input.set hash['value']
    # makes sure that we are leaving the field again
    page.execute_script("$('.#{field[:class].gsub(/\s/, ".")}').find('input, textarea').blur()")
    wait_until(10){ field.find(".status .ok") }  
  end
  
  wait_until{ all(".loading", :visible => true).size == 0 }
end

When "I fill in the metadata form as follows:" do |table|
  table.hashes.each do |hash|
    # Fills in the "_value" field it finds in the UL that contains
    # the "key" text. e.g. "Titel*" or "Copyright"
    text = filter_string_for_regex(hash['label'])

    list = find("ul", :text => /^#{text}/)
    if list.nil?
      raise "Can't find any input fields with the text '#{text}'"
    else
      if list[:class] == "Person"
        fill_in_person_widget(list, hash['value'], hash['options'])
      elsif list[:class] == "Keyword"
        fill_in_keyword_widget(list, hash['value'], hash['options'])
      elsif list[:class] == "MetaTerm"
        if list.has_css?("ul.meta_terms")
          set_term_checkbox(list, hash['value'])
        elsif list.has_css?(".madek_multiselect_container")
          select_from_multiselect_widget(list, hash['value'])
        else
          raise "Unknown MetaTerm interface element when trying to set '#{text}'"
        end
      elsif list[:class] == "MetaDepartment"
        puts "Sorry, can't set MetaDepartment to '#{text}', the MetaDepartment widget is too hard to test right now."

        #select_from_multiselect_widget(list, hash['value'])
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

# Can use "user" or "group" field name
When /^I type "([^"]*)" into the "([^"]*)" autocomplete field$/ do |string, field|
  type_into_autocomplete(field.to_sym, string)
end

When /^I pick "([^"]*)" from the autocomplete field$/ do |choice|
  pick_from_autocomplete(choice)
end

When /^I give "([^"]*)" permission to "([^"]*)" without saving$/ do |permission, subject|
  subject = :everybody if subject == "everybody"
  give_permission_to(permission, subject, false)
end

When /^I give "([^"]*)" permission to "([^"]*)"$/ do |permission, subject|
  wait_for_css_element(".public .line")
  permissions_container = find(".subject", :text => subject).find(:xpath, './..').find(".permissions")
  if not permissions_container.find(".#{permission} input").checked?
    permissions_container.find(".#{permission} input").click
  end
  
  step 'I save the permissions'
end

When /^I remove "([^"]*)" permission from "([^"]*)"$/ do |permission, subject|
  wait_for_css_element(".public .line")
  permissions_container = find(".subject", :text => subject).find(:xpath, './..').find(".permissions")
  if permissions_container.find(".#{permission} input").checked?
    permissions_container.find(".#{permission} input").click
  end
  
  step 'I save the permissions'
end

When /^I click(?: | on )the arrow next to "([^"]*)"/ do |string|
  click_on_arrow_next_to(string)
end

When /^I click the media entry titled "([^"]*)"/ do |title|
  click_media_entry_titled(title)
end

When /^I click the mediaset titled "([^"]*)"/ do |title|
  click_media_entry_titled(title)
end

When /^I check the media entry titled "([^"]*)"/ do |title|
  check_media_entry_titled(title)
end

When /^I check the media set titled "([^"]*)"/ do |title|
  check_media_entry_titled(title)
end

When /^I create a set titled "([^"]*)"/ do |title|
  create_set(title)
end

When /^I add the picture "([^"]*)" to the set "([^"]*)" owned by "([^"]*)"/ do |picture_title, set_title, owner|
    add_to_set(set_title, picture_title, owner)
end

When /^I toggle the favorite star on the media entry titled "([^"]*)"$/ do |title|
  entry = find_media_entry_titled(title)
  entry.find(:css, ".favorite_link").find("a").click
  sleep(0.5)
end

When /^I click the edit icon on the media entry titled "([^"]*)"$/ do |title|
  wait_until { find(".item_box") }
  page.execute_script("$('.actions').show()")
  entry = find_media_entry_titled(title)
  entry.find(".button_edit_active").click
  wait_until { find("#resource_edit") }
end

When /^I click the delete icon on the media entry titled "([^"]*)"$/ do |title|
  entry = find_media_entry_titled(title)
   # Fake some functions so that we automatically accept the confirmation dialog
   page.evaluate_script("window.alert = function(msg) { return true; }")
   page.evaluate_script("window.confirm = function(msg) { return true; }")
   entry.find(".delete_me").click
  sleep(0.5)
end

When /^I click the delete icon on the set titled "([^"]*)"$/ do |title|
  entry = find_media_entry_titled(title)
  # show controls
  page.execute_script '$(".item_box *:hidden").show();'
  sleep 0.5
  # click delete
  entry.find(".delete_me").click
  sleep(0.5)
  page.driver.browser.switch_to.alert.accept #accept confirm message
  sleep(5.5)
end

When /^I reload the page$/ do
  case Capybara::current_driver
    when :selenium
    visit page.driver.browser.current_url
    when :racktest
    visit [ current_path, page.driver.last_request.env['QUERY_STRING'] ].reject(&:blank?).join('?')
    when :culerity
    page.driver.browser.refresh
    else
    raise "unsupported driver, use rack::test or selenium/webdriver"
  end
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

When "all the entries controls become visible" do
  make_entries_controls_visible
end

When "I make sure I'm logged out" do
  if page.has_content?("Abmelden")
    step 'I follow "Abmelden"'
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

When /I choose the set "([^"]*)" from the media entry$/ do |set_name|
  wait_until {
    find(:xpath, "//div[@class='set-box' and @oldtitle]")
  }
  element = find(:xpath, "//div[@class='set-box' and @oldtitle]")
  unless element.nil?
    if element[:oldtitle] =~ /^#{set_name}/
      link = element.find("a")
      link.click
    end
  end
end


Then "the box should have a hires download link" do
    find(:css, "tr.download-unit").all("a").count.should == 1
end

Then "the box should not have a hires download link" do
    find(:css, "tr.download-unit").all("a").count.should == 0
end


# TODO: Make this generic so that we can use sentences like "with metadata" and
# "without metadata" etc.
When "I click the download button for ZIP with metadata" do
#     all(:css, "tr.download-unit").each do |tr|
#       para = tr.find("p.download-info")
#       if para.text =~ /^ZIP-Verzeichnis mit Datei und/
#         tr.all("a").first.click
#       end
#     end
end

When /^I see the set-box "(.+)"$/ do |title|
  sleep(0.5)
  assert find(:xpath, "//div[contains(@oldtitle,'#{title}')]")
end

When /^I expand the "(.+)" context group$/ do |name|
  find(:css, ".meta_context_group span", :text => name).click
end

Given "I am pending" do
  pending
end
