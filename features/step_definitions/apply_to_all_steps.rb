When /^I upload some media entries$/ do
  visit import_path
  step 'I attach the file "images/berlin_wall_01.jpg"'
  step 'I attach the file "images/berlin_wall_02.jpg"'
  step 'I attach the file "images/date_should_be_1990.jpg"'
  step 'I click on the link "Weiter"'
  step 'I wait until I am on the "/import/permissions" page'
end

Then /^I can apply meta data from one specific field to the same field of multiple other media entries of the collection$/ do
  step 'I click on the button "Berechtigungen speichern"'
  step 'I wait until I am on the "/import/meta_data" page'
  wait_until {all(".apply-to-all", :visible => true).size > 0}
  all(".apply-to-all").first.click
  find("a[data-overwrite='true']", :visible => true)
  find("a[data-overwrite='false']", :visible => true)
end

When /^I apply each meta datum field of one media entry to all other media entries of the collection using overwrite functionality$/ do
  step 'I click on the button "Berechtigungen speichern"'
  step 'I wait until I am on the "/import/meta_data" page'
  wait_until {all("form fieldset",visible: true).size > 0}
  step 'I change the value of each visible meta-data field'
  all("form fieldset",visible: true).each_with_index do |field_set,i|
    field_set.find(".apply-to-all").click
    field_set.find("a[data-overwrite='true']").click
    wait_until { field_set.all(".icon-checkmark").size > 0}
  end
end

When /^I apply each meta datum field of one media entry to all other media entries of the collection using apply on empty functionality$/ do
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
    field_set.find(".apply-to-all").click
    field_set.find("a[data-overwrite='false']").click
    wait_until { field_set.all(".icon-checkmark").size > 0}
  end
end

Then /^all other media entries have the same meta data values$/ do
  reference_media_entry = MediaEntryIncomplete.find find(".ui-resource[data-id]")["data-id"]
  @reference_meta_data = reference_media_entry.meta_data.where(:meta_key_id => MetaKey.where(id: @meta_data.map{|x| x["meta_key"]}))
  @current_user.media_resources.where(:type => "MediaEntryIncomplete").each do |media_entry|
    find(".ui-resource[data-id='#{media_entry.id}']").click
    step 'each meta-data value should be equal to the one set previously'
    meta_data = media_entry.meta_data.where(:meta_key_id => MetaKey.where(id: @meta_data.map{|x| x["meta_key"]}))
    expect(meta_data.map(&:to_s).sort).to be == @reference_meta_data.map(&:to_s).sort
  end
end

Then /^all other media entries have the same meta data values in those fields that were empty before$/ do
  reference_media_entry = MediaEntryIncomplete.find find(".ui-resource[data-id]")["data-id"]
  @current_user.media_resources.where(:type => "MediaEntryIncomplete").each do |media_entry|
    find(".ui-resource[data-id='#{media_entry.id}']").click
    @meta_data_before_apply[media_entry.id].each do |meta_datum|
      if meta_datum[:value].blank?
        expect(MediaResource.find(meta_datum[:media_resource_id]).meta_data.get(meta_datum[:meta_key_id]).to_s == reference_media_entry.meta_data.get(meta_datum[:meta_key_id]).to_s).to be_true
      elsif media_entry.id != reference_media_entry.id
        expect(MediaResource.find(meta_datum[:media_resource_id]).meta_data.get(meta_datum[:meta_key_id]).to_s == reference_media_entry.meta_data.get(meta_datum[:meta_key_id]).to_s).to be_false
      end
    end
  end
end
