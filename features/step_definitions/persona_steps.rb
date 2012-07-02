Given /^personas are loaded$/ do
  #puts "We'll just have to trust that the personas are loaded..." # (stop flooding the terminal)
  # MediaResource.count.zero?.should be_true

  # Persona.create("Adam") # Admin should be created first, he setting up the application
  # Persona.create("Normin")
  # Persona.create("Petra")
  # Persona.create("Beat")
  # Persona.create("Liselotte")
  # Persona.create("Norbert")

  # MediaResource.count.zero?.should be_false
end

# This fakes a currently logged in user session because that's much faster than going through the login form
# 2 million times :)
# The login form itself is tested in a separate scenario.
Given /^I am "(\w+)"$/ do |login|
  visit "/logout"
  visit "/db/login"
  fill_in "login", :with => login
  fill_in "password", :with => "password"
  click_link_or_button "Log in"
  @current_user = User.find_by_login(login.downcase)
  @current_user ||= FactoryGirl.create(:user, {:login => login})
end
