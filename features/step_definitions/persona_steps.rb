Given /^personas are loaded$/ do
  MediaResource.count.zero?.should be_true

  PersonaFactory.create("Adam")
  PersonaFactory.create("Normin")

  MediaResource.count.zero?.should be_false
end

Given /^I am "(\w+)"$/ do |persona_name|
  step 'I log in as "%s" with password "password"' % persona_name
  step 'I am logged in as "%s"' % persona_name
end