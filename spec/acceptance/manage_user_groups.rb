require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Manage user groups", %q{
  People want to work together in groups, so they need an editor where they can edit them.
} do



  background do
    set_up_world
    helmut = create_user("Helmut Kohl", "helmi", "schweinsmagen")
    gorbatschow = create_user("Mikhail Gorbachev", "gorbi", "glasnost")
    ronnie = create_user("Ronald Reagan", "ronnie", "hamburgers")
  end


  # I should be able to list my groups even if I don't really have any
  scenario "Go to my group list" do
    user = log_in_as("ronnie", "hamburgers")
    user.groups.count.should == 0
    click_on_arrow_next_to("Reagan, Ronald")
    click_link("Meine Gruppen")
    page.should have_content("Meine Gruppen")
    page.should have_content("Name der Gruppe")
  end

  # Let's make a new group
  scenario "Create a new group" do
    user = log_in_as("ronnie", "hamburgers")
    user.groups.count.should == 0
    click_on_arrow_next_to("Reagan, Ronald")
    click_link("Meine Gruppen")
    page.should have_content("Meine Gruppen")
    page.should have_content("Name der Gruppe")
    click_link("Neue Gruppe erstellen")
    fill_in("Name", :with => 'My Own Private Idaho')
    click_button("Gruppe erstellen")
    page.should have_content("My Own Private Idaho")
    page.should have_content("Reagan, Ronald")

    # The user has been automatically added to their newly created group,
    # so let's check for that
    user.groups.count.should == 1
  end

  # Let's make a new group and add some people
  scenario "Create a new group", :js => true do
    user = log_in_as("ronnie", "hamburgers")
    user.groups.count.should == 0
    click_on_arrow_next_to("Reagan, Ronald")
    click_link("Meine Gruppen")
    page.should have_content("Meine Gruppen")
    page.should have_content("Name der Gruppe")
    click_link("Neue Gruppe erstellen")
    fill_in("Name", :with => 'Cold War Crew')
    click_button("Gruppe erstellen")
    page.should have_content("Cold War Crew")
    page.should have_content("Reagan, Ronald")

    # The user has been automatically added to their newly created group,
    # so let's check for that
    user.groups.count.should == 1

    type_into_autocomplete(:add_member_to_group, "kohl")
    sleep(3)
    pick_from_autocomplete("Kohl, Helmut")
    
    type_into_autocomplete(:add_member_to_group, "gorb")
    sleep(3)
    pick_from_autocomplete("Gorbachev, Mikhail")

    user.groups.first.users.count.should == 3
    page.should have_content("Kohl, Helmut")
    page.should have_content("Gorbachev, Mikhail")
    
  end

 # Let's make a new group
  scenario "Create a new group", :js => true do
    user = log_in_as("ronnie", "hamburgers")
    user.groups.count.should == 0
    click_on_arrow_next_to("Reagan, Ronald")
    click_link("Meine Gruppen")
    page.should have_content("Meine Gruppen")
    page.should have_content("Name der Gruppe")
    click_link("Neue Gruppe erstellen")
    fill_in("Name", :with => 'Cold War Crew')
    click_button("Gruppe erstellen")
    page.should have_content("Cold War Crew")
    page.should have_content("Reagan, Ronald")

    # The user has been automatically added to their newly created group,
    # so let's check for that
    user.groups.count.should == 1

    type_into_autocomplete(:add_member_to_group, "kohl")
    sleep(3)
    pick_from_autocomplete("Kohl, Helmut")

    type_into_autocomplete(:add_member_to_group, "gorb")
    sleep(3)
    pick_from_autocomplete("Gorbachev, Mikhail")

    user.groups.first.users.count.should == 3
    page.should have_content("Kohl, Helmut")
    page.should have_content("Gorbachev, Mikhail")

    # Now we remove Helmut because he didn't play nice
    find("li", :text => 'Kohl, Helmut').find('a', :text => 'Löschen').click

    sleep(4)
    user.groups.first.users.count.should == 2
    user.groups.first.users.include?(User.where(:login => 'helmi').first).should == false
  end
  
end