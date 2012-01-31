Given /^personas are loaded$/ do
  MediaResource.count.zero?.should be_true

  PersonaFactory.create("Adam")
  PersonaFactory.create("Normin")

  MediaResource.count.zero?.should be_false
end