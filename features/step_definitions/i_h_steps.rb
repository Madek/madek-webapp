# -*- encoding : utf-8 -*-

Then /^I have a media_entry of type image including previews$/ do
 @media_entry = FactoryGirl.create(:media_entry_with_image_media_file, user: @me)
end

Then /^I have a media_entry of type video$/ do  
  @media_entry = 
    (FactoryGirl.create :media_entry_incomplete_for_movie, user: @me) \
    .set_as_complete
end

Then /^I have set up some departments with ldap references$/ do
  InstitutionalGroup.create([
   {:institutional_group_id => "4396.studierende", :institutional_group_name => "DKV_FAE_BAE.studierende", :name => "Bachelor Vermittlung von Kunst und Design"},
   {:institutional_group_id => "56663.dozierende", :institutional_group_name => "DDE_FDE_VID.dozierende", :name => "Vertiefung Industrial Design"} 
  ]) 
end

Then /^I have to confirm$/ do
  unless Capybara.current_driver == :poltergeist
    page.driver.browser.switch_to.alert.accept 
  end
end
