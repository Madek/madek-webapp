When /^I look at one of these pages then I can see the action bar:$/ do |table|
  table.hashes.each do |row|
    step 'I go to #{row page_type}'    
  end
end