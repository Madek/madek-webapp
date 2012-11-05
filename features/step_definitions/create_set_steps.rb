When /^I create a set through the context actions$/ do
  steps %Q{ 
    When I click the arrow next to my name
    And I follow "Meine Sets"
    And I hover the context actions menu
  }
  find(".action_menu .open_create_set_dialog").click
end

Then /^I see a dialog with an input field for the title$/ do
  wait_until { find(".dialog input.title") }
end

When /^I provide a title$/ do
  find(".dialog .create").click
  find(".dialog .errors").text.length.should > 0
  @title = "This is my new set"
  find(".dialog input.title").set @title
end

Then /^I can create a set with that title$/ do
  find(".dialog .create").click
end

When /^I created that set$/ do
  step 'I wait for the AJAX magic to happen'
end

Then /^Im redirectet to the detail view of that set$/ do
  find("h3").text.should == @title
end
