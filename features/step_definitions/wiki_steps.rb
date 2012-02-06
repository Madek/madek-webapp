Then /^I should be told I have no access and I need to log in$/ do
  step 'I should see "Bitte anmelden"'
end

Given /^there is a wiki page "([^"]*)"$/ do |name|
  @wikipage = WikiPage.new( :path => name, :title => name )
  @wikipage.save.should be_true
end

Given /^a wiki front page$/ do
  @frontpage = WikiPage.find_by_path_or_new ""
  @frontpage.save.should be_true
end

Given /^the main page links to it$/ do
  @frontpage.content = "[[" + @wikipage.path + "]]"
  @frontpage.save.should be_true
end

Then /^I should see the "([^"]*)" wiki page$/ do |name|
  step 'I should be on the "' + name + '" wiki page'
  page.body.should =~ /wiki_content/
end

Then /^I should see the wiki front page$/ do
  step 'I should be on the wiki'
  page.body.should =~ /wiki_content/
end

Then /^I should see the media entry$/ do
  step 'I should see "' + @media_entry.title + '"'
end

Given "there is a media entry" do
  # TODO: this doesn't work correctly yet. Only execute it once, since
  #       the upload step takes too much time
  unless @media_entry = MediaEntry.last
    step 'I upload some picture titled "baustelle osten"'
    @media_entry = MediaEntry.last # TODO: sorry, ugly
  end
end

When /^I add a line "([^"]*)" to the wiki front page and save$/ do |text|
  step "I go to the wiki"
  step 'I follow "Edit"'
  step 'I fill in "page_content" with "' + text + '"'
  step 'I press "Save page"'
end

When /^I add a link "([^"]*)" to it on the wiki front page and save$/ do |text|
  text = text.sub("xxx", @media_entry.id.to_s)
  step 'I add a line "' + text + '" to the wiki front page and save'
end

Then /^I should see the media entry (\d+)$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" is an admin$/ do |name|
  Group.find_or_create_by_name("Admin").users << (User.find_by_login name)
end

Then /^I should see a message that I'm not allowed to do that$/ do
  step 'I should see "You are not allowed to be here"'
end

Then /^I should see a "([^"]*)" link on the page$/ do |text|
  find_link( text ).should_not be_nil
end

Then 'there should be an image with title "$title"' do |title|
  expect {
    find("img[title='#{title}']")
  }.should_not raise_exception
end

Then 'I should land on the newly to be created "$name" page' do |name|
  step 'I should see "There is no such page. Do you want to"'
  step 'I should see a "create it" link on the page'
end

Then "show me the debugger" do
  debugger
end
