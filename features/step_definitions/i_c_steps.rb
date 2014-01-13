# -*- encoding : utf-8 -*-
 
Then /^I can apply meta data from one specific field to the same field of multiple other media entries of the collection$/ do
  step 'I click on the button "Berechtigungen speichern"'
  step 'I wait until I am on the "/import/meta_data" page'
  wait_until {all(".apply-to-all", :visible => true).size > 0}
  find(".apply-to-all a").click
  find("a[data-overwrite='true']", :visible => true)
  find("a[data-overwrite='false']", :visible => true)
end

Then /^I can add a new member to the group$/ do
  @added_user = User.where(User.arel_table[:id].not_eq(@current_user.id)).where(User.arel_table[:id].not_in(@group.users.map(&:id))).first
  find("input#add-user").set @added_user.to_s
  find("ul.ui-autocomplete li a", text: @added_user.to_s).click
end

Then /^I can choose from a set of labeled permissions presets instead of grant permissions explicitly$/ do
  step "I wait until there are no more ajax requests running"
  expect(all("tr[data-name='#{@user_with_userpermissions.name}'] select.ui-rights-role-select option").size).to be > 0
end

Then /^I can browse for similar entries$/ do
  @media_entry = MediaEntry.find all(".ui-resource[data-type='media-entry']").first[:"data-id"]
  all(".ui-resource[data-type='media-entry'] .ui-thumbnail-meta").first.click
  all(".ui-resource[data-type='media-entry'] .ui-thumbnail-action-browse").first.click
  current_path.should == browse_media_resource_path(@media_entry)
  page.should have_content "Nach vergleichbaren Inhalten stöbern"
end

Then /^I can delete an existing member from the group$/ do
  @removed_user = User.where(User.arel_table[:id].not_eq(@current_user.id)).where(User.arel_table[:id].in(@group.users.map(&:id))).first
  find("#user-list tr", :text => @removed_user.to_s).find(".button[data-remove-user]").click
  wait_until{all("#user-list tr", :text => @removed_user.to_s).size == 0}
end

Then /^I can delete that person$/ do
  expect{ @delete_link = find("tr#person_#{@person_without_meta_data.id} a",text: 'Delete')}.not_to raise_error
end

Then /^I can edit the permissions/ do
  permissions = @resource.userpermissions.where(user_id: @me).first
  orig_download_permissions = permissions.download
  find("tr[data-name='#{@me.name}']").find("input[name=download]").click
  find("button.primary-button[type=submit]").click
  wait_until{page.evaluate_script(%<$.active>) == 0}
  expect(@resource.userpermissions.find_by(user_id: @me).download).not_to eq orig_download_permissions
end

Then /^I can filter by the type of media resources$/ do
  find("[data-context-name='media_resources']").click
  find("[data-key-name='type']").click

  # MediaEntry
  find("[data-value='MediaEntry']").click
  wait_until {all(".ui-resource[data-id]").size > 0}
  expect(all(".ui-resource[data-id]").size == all(".ui-resource[data-id][data-type='media-entry']").size).to be_true
  find("[data-value='MediaEntry']").click

  # MediaSet
  find("[data-value='MediaSet']").click
  wait_until {all(".ui-resource[data-id]").size > 0}
  expect(all(".ui-resource[data-id]").size == all(".ui-resource[data-id][data-type='media-set']").size).to be_true
  find("[data-value='MediaSet']").click

  # FilterSet
  find("[data-value='FilterSet']").click
  wait_until {all(".ui-resource[data-id]").size > 0}
  expect(all(".ui-resource[data-id]").size == all(".ui-resource[data-id][data-type='filter-set']").size).to be_true
  find("[data-value='FilterSet']").click
end

Then /^I can go to the abstract of that context$/ do
  find(".ui-tabs-item a[href='#{context_abstract_path(@context)}']").click
  expect(current_path).to eq context_abstract_path @context
end

Then /^I can go to the vocabulary of that context$/ do
  find(".ui-tabs-item a[href='#{context_vocabulary_path(@context)}']").click
  expect(current_path).to eq context_vocabulary_path @context
end

Then /^I can not edit the permissions/ do
  permissions = @resource.userpermissions.where(user_id: @me).first
  orig_download_permissions = permissions.download
  find("tr[data-name='#{@me.name}']").find("input[name=download]").click
  expect{find("button.primary-button[type=submit]")}.to raise_error
end

Then /^I can not delete that person$/ do
  expect{ find("tr#person_#{@person_without_meta_data.id} a",text: 'Delete')}.to raise_error
end

Then /^I can select "(.*?)" to grant group permissions$/ do |group|
  #wait_until{ all("#addGroup a", text: "Gruppe hinz").size > 0 }
  # find("#addGroup a",text: "Gruppe hinz").click
  find("#addGroup input[type='text']").set group[0..10]
  find("ul.ui-autocomplete li a",text: group).click
end

### I can see 

Then /^I can see "(.*?)"$/ do |text|
  expect(page).to have_content text
end

Then(/^I can see a form for editing permissions$/) do
  find("form#ui-rights-management")
end

Then (/^I can see a success message$/) do
  expect(all("#messages .alert-success").size).to be > 0
end

Then (/^I can see all resources$/) do
  expect(find("#resources_counter").text.to_i).to eq MediaResource.count
end

Then (/^I can see at least "(.*?)" included resources$/) do |snum|
  wait_until(3*Capybara.default_wait_time){ all("ul#ui-resources-list li.ui-resource").size >= snum.to_i }
end

Then /^I can see every meta\-data\-value somewhere on the page$/ do
  @meta_data_by_context.each do |meta_context_name,meta_data|
    meta_data.each do |md|
      value= md[:value]
      case md[:type]
      when 'meta_datum_departments'
        expect(page).to have_content stable_part_of_meta_datum_departement(value)
      else
        expect(page).to have_content value
      end
    end
  end
end

Then (/^I can see exactly "(.*?)" included resources$/) do |snum|
  wait_until{ all("ul#ui-resources-list li.ui-resource").size == snum.to_i }
end

Then /^I can see instructions for an FTP import$/ do
  step %Q{I can see the text "#{@current_user.dropbox_dir_name}"}
  step %Q{I can see the text "#{@app_settings.ftp_dropbox_server}"}
  step %Q{I can see the text "#{@app_settings.ftp_dropbox_user}"}
  step %Q{I can see the text "#{@app_settings.ftp_dropbox_password}"}
end

Then (/^I can see more resources than before$/) do
  expect(find("#resources_counter").text.to_i).to be > @resources_counter
end

Then /^I can see my relations for that resource[s]*$/ do
  nodes = 
    if @media_set
      #MediaResource.descendants_and_set(@media_set, MediaResource.accessible_by_user(@current_user))
      MediaResource.connected_resources(@media_set, @current_user.media_resources)
    elsif @media_entry
      MediaResource.connected_resources(@media_entry, @current_user.media_resources)
    else
      MediaResource.filter(@current_user, @filter) 
    end
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last
  wait_until { !current_url.match(/http:\/\//).nil? }
  env = Rack::MockRequest.env_for(current_url)
  request = Rack::Request.new(env)
  visit url_for Rails.application.routes.recognize_path(current_url).merge({:insert_to_dom => "true", :only_path => true}).merge(request.params)
  # nodes
  node_data = JSON.parse(find("#graph-data")[:"data-nodes"])
  node_data.map{|n| n["id"]}.sort.should == nodes.map(&:id).sort
  nodes.each{|node| find(".node[data-resource-id='#{node.id}']")}
  # arcs
  arcs = MediaResourceArc.connecting nodes
  arc_data = JSON.parse(find("#graph-data")[:"data-arcs"])
  arcs.each{|arc| arc_data.any?{|a| a["child_id"] == arc.child_id and a["parent_id"] == arc.parent_id}.should be_true}
  arcs.each{|arc| find(".arc[parent_id='#{arc.parent_id}'][child_id='#{arc.child_id}']")}
end

Then /^I can see several images$/ do
  wait_until{all("li[data-media-type='image']").size > 0}
end

Then /^I can see several items of class "(.*?)" in the class "(.*?)"$/ do |li_class, ul_class|
  expect( all("ul.#{ul_class} li.#{li_class}").size ).to be > 1
end

Then /^I can see several resources$/ do
  wait_until{ all("li.ui-resource").size > 0 }
end

Then /^I can see that there are no previews$/ do
  find("table.previews tbody")
  expect(all("table.previews tbody tr").size).to eq 0
end

Then /^I can see that there are several previews$/ do
  expect(all("table.previews tbody tr").size).to be > 1
end

Then /^I can see the "(.*?)" link$/ do |anchor_text|
  expect(has_link?(anchor_text)).to be_true
end

Then /^I can see the delete action for media resources where I am responsible for$/ do
  all(".ui-resource[data-id]").each do |resource_el|
    media_resource = MediaResource.find resource_el["data-id"]
    if @current_user.authorized?(:delete, media_resource)
      resource_el.find("[data-delete-action]")
    end
  end
end

Then /^I can see the delete action for this resource$/ do
  find(".ui-body-title-actions .primary-button").click
  find("[data-delete-action]")
end

Then /^I can see that the fieldset with "(.*?)" as meta\-key is required$/ do |meta_key_id|
  expect(find("fieldset.error[data-meta-key='#{meta_key_id}']")).to be
end

Then /^I can see the filter panel$/ do
  wait_until{ all(".filter-panel").size > 0}
end

Then(/^I can see the following permissions\-state:$/) do |table|
  table.rows.each do |row|
    user = User.find_by_login row[0]
    action = row[1]
    permission = row[2]
    tr = find("tr[data-id='#{user.id}']")
    input = tr.find("input[name='#{action}']")
    if permission == "true"
      expect(input).to be_checked
    else
      expect(input).not_to be_checked
    end
  end
end

Then /^I can see the text "(.*?)"$/ do |text|
  expect(page).to have_content text
end

Then /^I can see the permissions dialog$/  do
  find(".modal .ui-rights-management")
end

Then /^I can see the provided title and the used filter settings$/ do
  page.should have_content @title
  @used_filter.each do |filter|
    find("a[href*='#{filter[:key_name].gsub(/\s/, "+")}%5D%5Bids%5D%5B%5D=#{filter[:value]}']")
  end
end

Then /^I can see the preview$/ do
  expect(find("img.vjs-poster")).to be
end

Then(/^I can see the resource(\d+) in the clipboard$/) do |d|
  resource = @resources[d.to_i]
  find(".ui-clipboard .ui-resource[data-id='#{resource.id}']",visible: true)
end

###

And /^I can watch the video$/ do
  find(".vjs-big-play-button",visible: true).click()
  expect( all(".vjs-big-play-button",visible: true).size ).to eq 0
  wait_until(10){all(".vjs-big-play-button",visible: true).size > 0 }
end

####### I cannot ##### #############

Then /^I can not see any alert$/ do
  wait_until{all('.ui-alert').size == 0}
end

Then /^I cannot see the delete action for media resources where I am not responsible for$/ do
  all(".ui-resource[data-id]").each do |resource_el|
    media_resource = MediaResource.find resource_el["data-id"]
    if not @current_user.authorized?(:delete, media_resource)
      resource_el.all("[data-delete-action]").size.should == 0
    end
  end
end

Then /^I cannot see the delete action for this resource$/ do
  all(".ui-body-title-actions [data-delete-action]").size.should == 0
end

Then /^I cannot see "(.*?)"$/ do |text|
  expect(page).not_to have_content text
end

### I change 

Then /^I change some input field$/ do
  find("input[type=text]").set "123"
end

Then /^I change the group name$/ do
  find("#show-edit-name").click
  @name = Faker::Name.last_name
  find("input#group-name").set @name
end

Then /^I change the settings for that filter set$/ do
  wait_until { all(".ui-preloader", :visible => true).size == 0 }
  wait_until { all("#ui-side-filter-blocking-layer", :visible => true).size == 0 }
  find("#ui-side-filter-reset").click
  step 'I use some filters'
end

Then /^I change the value of each meta\-data field of each context$/  do

  @meta_data_by_context=HashWithIndifferentAccess.new

  all("ul.contexts li").each do |context|
    context.find("a").click()
    Rails.logger.info ["changin metadata for context", context[:'data-context-name']]
    step 'I change the value of each visible meta-data field'
    @meta_data_by_context[context[:'data-context-name']] = @meta_data
  end
end

Then /^I change the value of each visible meta\-data field$/ do
  @meta_data= []
  all("form fieldset",visible: true).each_with_index do |field_set,i|
    type = field_set[:'data-type']
    meta_key = field_set[:'data-meta-key']


    case type

    when 'meta_datum_string'
      @meta_data[i] = HashWithIndifferentAccess.new(
        value: Faker::Lorem.words.join(" "),
        meta_key: meta_key,
        type: type)
      if field_set.all("textarea").size > 0
        field_set.find("textarea").set(@meta_data[i][:value])
      else
        field_set.find("input[type='text']").set(@meta_data[i][:value])
      end

    when 'meta_datum_people' 
      # remove all existing 
      field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
      @people ||= Person.all
      random_person =  @people[rand @people.size]
      @meta_data[i] = HashWithIndifferentAccess.new(
        value: random_person.to_s,
        meta_key: meta_key,
        type: type)
      field_set.find("input.form-autocomplete-person").set(random_person.to_s)
      page.execute_script %Q{ $("input.form-autocomplete-person").trigger("change") }
      wait_until{  field_set.all("a",text: random_person.to_s).size > 0 }
      field_set.find("a",text: random_person.to_s).click

    when 'meta_datum_date' 
      @meta_data[i] = HashWithIndifferentAccess.new(
        value: Time.at(rand Time.now.tv_nsec).iso8601,
        meta_key: meta_key,
        type: type)
        field_set.find("input", visible: true).set(@meta_data[i][:value])

    when 'meta_datum_keywords'

      field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
      @kws ||= MetaTerm.joins(:keywords).select("de_ch").uniq.map(&:de_ch).sort
      random_kw = @kws[rand @kws.size]
      @meta_data[i] = HashWithIndifferentAccess.new(
        value: random_kw,
        meta_key: meta_key,
        type: type)
      field_set.find("input", visible: true).set(random_kw)
      page.execute_script %Q{ $("input.ui-autocomplete-input").trigger("change") }
      wait_until{  field_set.all("a",text: random_kw).size > 0 }
      field_set.find("a",text: random_kw).click


    when 'meta_datum_meta_terms'
      if field_set['data-is-extensible-list']
        field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
        field_set.find("input",visible: true).click
        page.execute_script %Q{ $("input.ui-autocomplete-input").trigger("change") }
        wait_until{ field_set.all("ul.ui-autocomplete li a",visible: true).size >0 }
        targets = field_set.all("ul.ui-autocomplete li a",visible: true)
        targets[rand targets.size].click
        wait_until{ field_set.all("ul.multi-select-holder li.meta-term").size > 0}
        @meta_data[i] = HashWithIndifferentAccess.new(
          value: field_set.first("ul.multi-select-holder li.meta-term").text, 
          type: type,
          meta_key: meta_key) 
      else
        checkboxes = field_set.all("input",type: 'checkbox', visible: true)
        checkboxes.each{|c| c.set false}
        checkboxes[rand checkboxes.size].click
        @meta_data[i] = HashWithIndifferentAccess.new(
          value: field_set.all("input", type: 'checkbox', visible: true,checked: true).first.find(:xpath,".//..").text,
          meta_key: meta_key,
          type: type) 
      end

    when 'meta_datum_departments' 
      field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
      field_set.find("input",visible: true).click
      directly_chooseable= field_set.all("ul.ui-autocomplete li:not(.has-navigator) a",visible: true)
      directly_chooseable[rand directly_chooseable.size].click
      @meta_data[i] = HashWithIndifferentAccess.new(
        value: field_set.first("ul.multi-select-holder li.meta-term").text, 
        type: type,
        meta_key: meta_key) 
    else
      rais "Implement this case" 
    end

    Rails.logger.info ["setting metadata filed value", field_set[:'data-meta-key'], @meta_data[i] ]

  end
end


###  I click
 
Then (/^I click on "(.*?)"$/) do |text|
  wait_until{ all("a, button", text: text, visible: true).size > 0}
  find("a, button",text: text).click
end

Then /^I click on "(.*?)" inside the autocomplete list$/ do |text|
  wait_until{  all("ul.ui-autocomplete li").size > 0 }
  find("ul.ui-autocomplete li a",text: text).click
end

Then /^I click on my first media entry$/ do
  all("ul.ui-resources li[data-type='media-entry']").first.find("a").click
end

When(/^I click on the details link of the first row$/) do
  all("tr a.details").first.click
end

Then /^I click on show me more of the featured sets$/ do
  find("#featured-set a").click
end

Then /^I click on show me more of the catalog$/ do
  find("#catalog a").click
end

Then /^I click on the "([^\"]*?)" permission for "([^\"]*?)"$/ do |permission, user|
  find("tr[data-name='#{user}'] input[name='#{permission}']").click
end


When(/^I click on the "(.*?)" permission until it is "(.*?)"$/) do |permission, pvalue|
  input_element = find("input[name='userpermission[#{permission}]']")

  begin
    input_element.click
    done = 
      case pvalue
      when "false"
        not input_element.checked?
      when "true"
        input_element.checked?
      else
        raise "you should never gotten here"
      end
  end while not done

end


When /^I click on the "([^\"]*?)" permission for "([^\"]*?)" until it is "([^\"]*?)"$/ do |permission, user_login, pvalue|
  user = User.find_by_login user_login
  td_element = find("tr[data-name='#{user.to_s}']  td.ui-rights-check.#{permission}")
  input_element = td_element.find("input[name='#{permission}']")

  input_element.instance_eval do
    def mixed? 
      self.value == "mixed"
    end
  end
  
  begin
    input_element.click
    done = 
      case pvalue
      when "false"
        not input_element.mixed? and not input_element.checked?
      when "true"
        not input_element.mixed? and input_element.checked?
      when "mixed"
        input_element.mixed?
      else
        raise "you should never gotten here"
      end
  end while not done

end


When(/^I click on the public "(.*?)" permission until it is "(.*?)"$/) do |permission, pvalue|
  # there is only one public row in it's own table
  td_element = find(".ui-rights-management-public table tr td.ui-rights-check.#{permission}")
  input_element = td_element.find("input[name='#{permission}']")
  begin
    input_element.click
    done = 
      case pvalue
      when "false"
        not input_element.checked?
      when "true"
        input_element.checked?
      else
        raise "you should never gotten here"
      end
  end while not done
end

Then /^I click on the button "(.*?)"$/ do |button_text|
  wait_until{all("button:not([disabled])", text: button_text).size > 0 }
  find("button:not([disabled])",text: button_text).click
end

Then (/^I click on the clickable with text "(.*?)" and with the value "(.*?)" for the attribute "(.*?)"$/) do |text, value, attribute_name|
  find("a[#{attribute_name}=#{value}], button[#{attribute_name}=#{value}]",text: text).click
end

Then /^I click on the database login tab$/ do
  find("#database-user-login-tab").click
end

Then /^I click on the explore tab$/ do
  find("a#to-explore").click
end

Then /^I click on the help tab$/ do
  find("a#to-help")
end

Then /^I click on the icon of the author fieldset$/ do
  find("fieldset[data-meta-key='author'] a.form-widget-toggle").click
end

Then /^I click on the link "([^\"]*?)"$/ do |link_text|
  wait_until{ all("a", text: link_text, visible: true).size > 0}
  find("a",text: link_text).click
end 


When /^I click on the link with the id "(.*?)"$/  do |id|
  find("##{id}").click
end

Then /^I click on the link "([\s\w]*?)" of the individual_meta_context "([\s\w]*?)"$/ do |link_text,individual_meta_context|
  find("table.individual_meta_contexts tr.individual_meta_context[data-name='#{individual_meta_context}']") \
    .find("a",text: link_text).click
end 

Then /^I click on the link "([\s\w]*?)" of the meta_context "([\s\w]*?)"$/ do |link_text,meta_context|
  find("table.meta_contexts tr.meta_context[data-name='#{meta_context}']") \
    .find("a",text: link_text).click
end

Then /^I click on the link "(.*?)" inside of the dialog$/ do |link_text|
  step 'I wait for the dialog to appear'
  find("a",text: link_text).click
end

Then /^I click on the submit button$/ do
  find("button[type='submit']").click
end

Then /^I click on the ZHdK\-Login$/ do
  find("a#zhdk-user-login-tab").click
end

Then (/^I click on the first a tag in the class "(.*?)"$/) do |_class|
  all(".#{_class} a").first.click
end

Then /^I click the primary action of this dialog$/ do
  find(".ui-modal .primary-button").click
end

Then /^I click the submit input$/ do
  find("input[type='submit']").click
end

Then /^I click the submit button$/ do
  find("button[type='submit']").click
end

Then /^I close the modal dialog\.$/ do
  find(".modal a[data-dismiss='modal']").click
  wait_until(2){all(".modal-backdrop").size == 0}
end

Then /^I choose to list only files with missing metadata$/ do
  find("input#display-only-invalid-resources").click
end

Then /^I configure some logo_url as the logo of my instance$/  do
  @logo_url="http://somwhere.com/some_logo.png"
  visit '/app_admin/settings/edit'
  find("input#app_settings_logo_url").set(@logo_url)
  find("*[type=submit]").click()
end

Then /^I confirm the browser dialog$/ do
  unless Capybara.current_driver == :poltergeist
    page.driver.browser.switch_to.alert.accept 
  end
end

Then /^I create a dropbox$/ do
  step 'I click on the link "Dropbox erstellen" inside of the dialog'
end
