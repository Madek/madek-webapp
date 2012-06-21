Then /^I should see an image rotation of the splashscreen set$/ do
  wait_until(30) { find(".nivo-caption") }
  MediaSet.find(AppSettings.splashscreen_slideshow_set_id).media_entries.map(&:title).should include find(".nivo-caption strong").text
end