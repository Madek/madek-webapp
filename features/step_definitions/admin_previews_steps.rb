Given /^I have a media_entry of type image including previews$/ do
 @media_entry = FactoryGirl.create(:media_entry, user: @me)
end

Given /^All previews are deleted for the media_entry/ do
  @media_entry.media_file.previews.destroy_all
end

Then /^I can see that there are no previews$/ do
  expect(all("table.previews tbody tr").size).to eq 0
end

Then /^I can see that there are several previews$/ do
  expect(all("table.previews tbody tr").size).to be > 1
end

Given /^I have a media_entry of type video$/ do  
  @media_entry = 
    (FactoryGirl.create :media_entry_incomplete_for_movie, user: @me) \
    .set_as_complete
end


Given /^I remember the number of ZencoderJobs$/ do
  @zencoder_jobs_number = all("table.zencoder-jobs tbody tr").size rescue 0
end

Then /^A new ZencoderJob has been added$/ do
  expect( all("table.zencoder-jobs tbody tr").size ).to eq (@zencoder_jobs_number + 1)
end

Then /^The state of the newest ZencoderJob is "(.*?)"$/ do |state|
  expect(find("table.zencoder-jobs tbody tr td.state").text).to eq  state
end
