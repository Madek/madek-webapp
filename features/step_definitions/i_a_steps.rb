# -*- encoding : utf-8 -*-


Then /^I a see the graph of the resource "(.*?)"$/ do |resource|
    visit "/visualization/#{resource}"
end

Then /^I accept the usage terms if I am supposed to do so$/ do
  if all("h3",text: "Nutzungsbedingungen").size > 0
    find("button",text: "Akzeptieren").click
  end
end

Then  /^I add some links for footer in the admin interface$/ do
  visit '/app_admin/settings/edit'
  @links={"THE SOMEWHERE LINK" => "http://somwhere.com", "THE NOWHERE LINK" => "http://nowhere.com"}
  find("textarea#app_settings_extra_yaml_footer_links").set(@links.to_yaml)
  find("*[type='submit']").click()
end

Then /^I add the resource to the given set$/ do
  wait_until{all(".ui-modal input.ui-search-input").size > 0}
  find(".ui-modal input.ui-search-input").set(@set.title)
  wait_until{all("ol.ui-set-list li",text: @set.title).size > 0 }
  expect(all("ol.ui-set-list li").size).to eq 1
  find("ol.ui-set-list li input[type='checkbox']#parent_resource_#{@set.id}").click
  find(".ui-modal button.primary-button").click
  wait_until{all(".modal-backdrop").size == 0}
  wait_until{all(".ui-alert.confirmation",visible: true).size > 0 }
end


When(/^I add the resource(\d+) to the clipboard$/) do |ns|
  i = ns.to_i
  id = @resources[i].id
  visit "/media_resources/#{id}"
  find("a[data-clipboard-toggle]").click
  wait_until{page.evaluate_script(%<$.active>) == 0}
  wait_until{find(".ui-clipboard li.ui-resource[data-id='#{id}']",visible: false)}
end

Then /^I add "(.*?)" to grant user permissions$/ do |name|
  wait_until{all(".ui-modal").size > 0}
end


### i apply ####################

Then /^I apply each meta datum field of one media entry to all other media entries of the collection using apply on empty functionality$/ do
  step 'I click on the button "Berechtigungen speichern"'
  step 'I wait until I am on the "/import/meta_data" page'
  wait_until {all("form fieldset",visible: true).size > 0}
  step 'I change the value of each visible meta-data field'
  @meta_data_before_apply = {}
  @current_user.media_resources.where(:type => "MediaEntryIncomplete").each do |mr|
    @meta_data_before_apply[mr.id] = []
    @meta_data.each do |md|
      meta_datum = mr.meta_data.get(md["meta_key"], true)
      @meta_data_before_apply[mr.id] << {:value => meta_datum.value, 
        :meta_key_id => meta_datum.meta_key_id, 
        :media_resource_id => mr.id
      }
    end
  end
  all("form fieldset",visible: true).each_with_index do |field_set,i|
    field_set.find(".apply-to-all a").click
    field_set.find("a[data-overwrite='false']").click
    wait_until { field_set.all(".icon-checkmark").size > 0}
  end
end

Then /^I apply each meta datum field of one media entry to all other media entries of the collection using overwrite functionality$/ do
  step 'I click on the button "Berechtigungen speichern"'
  step 'I wait until I am on the "/import/meta_data" page'
  wait_until {all("form fieldset",visible: true).size > 0}
  step 'I change the value of each visible meta-data field'
  all("form fieldset",visible: true).each_with_index do |field_set,i|
    field_set.find(".apply-to-all a").click
    field_set.find("a[data-overwrite='true']").click
    wait_until { field_set.all(".icon-checkmark").size > 0}
  end
end


### I am  ####################################
 

Then /^I am able to leave the page$/ do
  @current_path.should_not eq page.current_path
end


Then /^I am getting redirected to the (new|updated) filter set$/ do |either_or|
  wait_until{ current_path =~ /filter_sets/ }
end

Then /^I am going to import images$/ do
  @previous_media_entries = MediaEntry.all.to_a
  @previous_media_sets = MediaSet.all.to_a
  @previous_zencoder_jobs = ZencoderJob.all.to_a
end

Then /^I am logged in$/ do
  expect(find("a#user-action-button", text: "Normin")).not_to raise_error
end

Then /^I am logged in as "(.*?)"$/ do |first_name|
  expect(find("a#user-action-button", text: first_name)).not_to raise_error
end

Then /^I am on the catalog page$/ do
  expect(find ".app.view-explore-catalog").to be
end

Then /^I am on the content assigned to me page$/ do
  expect(current_path).to eq "/my/entrusted_media_resources"
end

Then /^I am on the dashboard$/ do
  visit "/"
end

Then /^I am on a "(.*?)" page$/ do |path|
  expect(current_path).to match path
end

Then /^I am on the my groups page$/ do
  expect(current_path).to eq "/my/groups"
end

Then /^I am on the my keywords page$/ do
  expect(current_path).to eq "/my/keywords"
end

Then /^I am on the my favorites$/ do
  expect(current_path).to eq "/my/favorites"
end

Then /^I am on the my resources page$/ do
  expect(current_path).to eq "/my/media_resources"
end

Then /^I am on the "(.*?)" page$/ do |path|
  expect(current_path).to eq path
end

Then /^I am on the page of the resource$/ do
  case @resource.type
  when "MediaSet" 
    wait_until{ current_path == media_set_path(@resource)}
  when "MediaEntry" 
    wait_until{ current_path == media_entry_path(@resource)}
  else
    raise
  end
end

Then /^I am on the view permissions page of the resource$/  do
  wait_until{ current_url.match /_action\=view/ }
  expect(current_path).to eq "/permissions/edit"
  expect(current_url).to match /_action\=view/
  expect(current_url).to match /media_resource_id\=#{@resource.id}/
end


Then /^I am not the responsible person for that resource$/ do
  expect(find("tr[data-is-current-user='true'] td.ui-rights-owner input")).not_to be_checked
end

Then /^I am redirected to the admin people list$/ do
  expect(current_path).to eq "/app_admin/people"
end

Then /^I am redirected to the main page$/ do
  expect(current_path).to eq "/my"
end

Then /^I am signed\-in as "(.*?)"$/ do |login|
  visit "/"
  find("a#database-user-login-tab").click
  find("input[name='login']").set(login)
  find("input[name='password']").set('password')
  find("button[type='submit']").click
  @me = @current_user = User.find_by_login login
end

Then (/^I am the last editor of the media entry with the id "(.*?)"$/) do |id|
  expect(MediaEntry.find(id).editors.reorder("edit_sessions.created_at DESC").first).to be == @me
end

Then /^I am the responsible person for that resource$/ do
  expect(find("tr[data-is-current-user='true'] td.ui-rights-owner input")).to be_checked
end

### 
 
Then /^I attach the file "(.*?)"$/ do |file_name|
  attach_file find("input[type='file']")[:id], Rails.root.join("features","data",file_name)
end


Then /^I am on the edit page of the resource$/ do
  expect(current_path).to eq edit_media_resource_path @resource
end

Then /^I am on the edit page of the filter_set$/  do
  expect(current_path).to eq edit_filter_set_path(@filter_set)
end

Then /^I am on the explore page$/ do
  expect(current_path).to eq "/explore"
end

Then /^I am on the featured sets set page$/ do
  expect(current_path).to eq "/explore/featured_set"
end

Then /^I am on the help page$/ do
  binding.pry
end

Then /^I am on the page of my first media_entry$/ do
  @media_entry = @me.media_entries.reorder(:id).first
  expect(current_path).to eq  media_entry_path(@media_entry)
end

Then /^I am redirected to the media archive$/ do
  expect(current_path).to eq "/my"
end

Then /^I am on the group page with id "(.*?)"$/ do |group_id|
  expect(current_path).to eq "/app_admin/groups/#{group_id}"
end

Then /^I am on the page where I can add a user to the group with id "(.*?)"$/ do |group_id|
  expect(current_path).to eq "/app_admin/groups/#{group_id}/form_add_user"
end
