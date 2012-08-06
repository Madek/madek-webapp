# coding: utf-8

Then /^I see a block of resources showing my content$/ do
  step 'I wait for the AJAX magic to happen'
	all(".media_resources.index.grid")[0].find(".page_title_left").should have_content("Meine Inhalte")
end

Then /^I can choose to continue to a list of all my content$/ do
	all(".media_resources.index.grid")[0].find(".buttons a", :text => "Alle meine Inhalte")
end

Then /^I see a block of resources showing content assigned to me$/ do
	all(".media_resources.index.grid")[1].find(".page_title_left").should have_content("Mir anvertraute Inhalte")
end

Then /^I can choose to continue to a list of all content assigned to me$/ do
	all(".media_resources.index.grid")[1].find(".buttons a", :text => "Alle mir anvertrauten Inhalte")
end

Then /^I see a block of resources showing content available to the public$/ do
	all(".media_resources.index.grid")[2].find(".page_title_left").should have_content("Öffentliche Inhalte")
end

Then /^I can choose to continue to a list of all content available to the public$/ do
	all(".media_resources.index.grid")[2].find(".buttons a", :text => "Alle öffentlichen Inhalte")
end
