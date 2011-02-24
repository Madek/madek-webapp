require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Manipulate Metadata framework and metadata", %q{
  In order to use the system, we need some metadata contexts, keys, etc.
  These tests create the metadata contexts and some metadata.
} do


  background do
    set_up_world
    user = create_user("Chuck Norris", "chuck_norris", "happyBunnies")
    group = create_group("Admin")
    add_user_to_group(user, group)
    log_in_as("chuck_norris", "happyBunnies")
  end
  
  scenario "Create a new context", :js => true do
    visit homepage
    click_on_arrow_next_to("Norris, Chuck")
    click_link("Admin")
    click_on_arrow_next_to("Meta")
    click_link("Contexts")
    click_link("+")
    wait_for_css_element("#new_meta_context") # The form where you can enter the context's attributes
    fill_in "Name", :with => "Kitten Classifications"
    fill_in "meta_context_meta_field_label_de_CH", :with => "Kätzchen-Klassifikationen"
    fill_in "meta_context_meta_field_label_en_GB", :with => "Kitten Classifications"
    click_button("Create")
    MetaContext.where(:name => "Kitten Classifications").exists?.should == true
  end


end
