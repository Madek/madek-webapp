require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Set up basic MAdeK system the way the ZHdK uses it", %q{
  This step imports a set of default settings from a YAML file so that media
  entries can be added and manipulated in subsequent steps.
} do


  scenario "Import the basic YAML file" do
    set_up_world
  end


end