Then /^I should receive a file$/ do |file|
  result = page.response_headers['Content-Type'].should == "application/octet-stream"
end